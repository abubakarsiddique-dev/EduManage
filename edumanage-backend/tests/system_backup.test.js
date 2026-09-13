const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');
const {
  createSnapshot,
  verifySnapshot,
  restoreSnapshot,
  computeChecksum,
  clearSnapshotsRegistry,
} = require('../src/modules/system/backup.service');

test('System Backup & Snapshot Engine Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = null;

  try {
    // 0. Authenticate admin for route tests
    await t.test('Admin logs in to acquire token for backup endpoints', async () => {
      const res = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'admin@edumanage.edu',
          password: 'Password@123',
        }),
      });

      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.ok(json.data.token);
      adminToken = json.data.token;
    });

    // 1. Unit: createSnapshot creates deep snapshot with checksum and stats
    await t.test('createSnapshot builds valid point-in-time snapshot', () => {
      const mockDb = {
        collections: {
          users: [{ id: 'u1', name: 'Alice' }],
          classes: [{ id: 'c1', name: 'Grade 10' }],
        },
      };

      const snapshot = createSnapshot(
        { reason: 'Unit test snapshot', triggeredBy: 'test_runner' },
        mockDb
      );

      assert.ok(snapshot.id.startsWith('snap_'));
      assert.strictEqual(snapshot.version, '1.5.0');
      assert.strictEqual(snapshot.reason, 'Unit test snapshot');
      assert.strictEqual(snapshot.triggeredBy, 'test_runner');
      assert.ok(snapshot.checksum.startsWith('sha256:'));
      assert.strictEqual(snapshot.stats.totalRecords, 2);
      assert.strictEqual(snapshot.stats.collections.users, 1);
      assert.strictEqual(snapshot.stats.collections.classes, 1);
      assert.deepStrictEqual(snapshot.data, mockDb.collections);
    });

    // 2. Unit: verifySnapshot verifies authentic snapshot and detects tampering
    await t.test('verifySnapshot confirms authentic and flags tampered payloads', () => {
      const mockData = { students: [{ id: 's1', name: 'Bob' }] };
      const authenticChecksum = computeChecksum(mockData);

      const authenticSnapshot = {
        id: 'snap_test_01',
        timestamp: new Date().toISOString(),
        checksum: authenticChecksum,
        data: mockData,
      };

      const validResult = verifySnapshot(authenticSnapshot);
      assert.strictEqual(validResult.valid, true);
      assert.strictEqual(validResult.recalculatedChecksum, authenticChecksum);

      // Tampered data
      const tamperedSnapshot = {
        ...authenticSnapshot,
        data: { students: [{ id: 's1', name: 'Eve Hacked' }] },
      };

      const invalidResult = verifySnapshot(tamperedSnapshot);
      assert.strictEqual(invalidResult.valid, false);
      assert.ok(invalidResult.error);
      assert.notStrictEqual(invalidResult.recalculatedChecksum, authenticChecksum);
    });

    // 3. Unit: restoreSnapshot restores database collections
    await t.test('restoreSnapshot restores state from valid snapshot and rejects corrupted', () => {
      const originalCollections = {
        users: [{ id: 'orig_1', email: 'orig@school.edu' }],
      };
      const restoredTarget = {
        users: [{ id: 'restored_1', email: 'restored@school.edu' }],
      };

      const mockDb = {
        collections: JSON.parse(JSON.stringify(originalCollections)),
        _save: () => {},
      };

      const snapshotToRestore = {
        id: 'snap_restore_01',
        timestamp: new Date().toISOString(),
        checksum: computeChecksum(restoredTarget),
        data: restoredTarget,
      };

      const result = restoreSnapshot(snapshotToRestore, mockDb);
      assert.strictEqual(result.restored, true);
      assert.deepStrictEqual(mockDb.collections, restoredTarget);

      // Attempt restoring tampered snapshot
      const corruptedSnapshot = {
        ...snapshotToRestore,
        data: { users: [{ id: 'corrupted' }] },
      };

      assert.throws(() => {
        restoreSnapshot(corruptedSnapshot, mockDb);
      }, /Snapshot integrity verification failed/);
    });

    // 4. Integration: POST /api/v1/system/backups requires admin auth and creates snapshot
    await t.test('POST /api/v1/system/backups creates snapshot with admin authorization', async () => {
      // Unauthenticated fails
      const unauthRes = await fetch(`${baseUrl}/system/backups`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason: 'Unauthorized test' }),
      });
      assert.strictEqual(unauthRes.status, 401);

      // Authenticated admin succeeds
      const authRes = await fetch(`${baseUrl}/system/backups`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({ reason: 'Integration Test Backup' }),
      });

      assert.strictEqual(authRes.status, 201);
      const json = await authRes.json();
      assert.strictEqual(json.success, true);
      assert.ok(json.data.id);
      assert.ok(json.data.checksum);
      assert.strictEqual(json.data.reason, 'Integration Test Backup');
    });

    // 5. Integration: GET /api/v1/system/backups lists metadata
    await t.test('GET /api/v1/system/backups lists snapshot records', async () => {
      const res = await fetch(`${baseUrl}/system/backups`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });

      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.ok(Array.isArray(json.data));
      assert.ok(json.count >= 1);
      assert.ok(json.data[0].id);
      assert.ok(json.data[0].checksum);
      assert.strictEqual(json.data[0].data, undefined); // raw data excluded from list
    });

    // 6. Integration: POST /api/v1/system/backups/verify verifies payload
    await t.test('POST /api/v1/system/backups/verify checks payload integrity', async () => {
      const payload = {
        snapshot: {
          id: 'snap_mock',
          checksum: computeChecksum({ test: [1, 2] }),
          data: { test: [1, 2] },
        },
      };

      const res = await fetch(`${baseUrl}/system/backups/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify(payload),
      });

      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.strictEqual(json.report.valid, true);
    });
  } finally {
    clearSnapshotsRegistry();
    server.close();
  }
});
