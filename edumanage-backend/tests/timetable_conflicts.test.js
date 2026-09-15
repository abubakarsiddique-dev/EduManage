const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

test('Timetable Collision Guard & Schedule Validation API Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = null;
  let teacherToken = null;
  const runId = Date.now();
  const testTeacher = `Prof. Test-${runId}`;
  const testRoom = `Room-${runId}`;
  const testClassA = `Grade-A-${runId}`;
  const testClassB = `Grade-B-${runId}`;
  const testClassC = `Grade-C-${runId}`;
  const createdIds = [];

  try {
    await t.test('Authenticate admin and teacher', async () => {
      const adminRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'admin@edumanage.edu', password: 'Password@123' }),
      });
      assert.strictEqual(adminRes.status, 200);
      const adminData = await adminRes.json();
      adminToken = adminData.data.token;

      const teacherRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'john.smith@edumanage.edu', password: 'Password@123' }),
      });
      assert.strictEqual(teacherRes.status, 200);
      const teacherData = await teacherRes.json();
      teacherToken = teacherData.data.token;
    });

    await t.test('POST /timetable/validate detects interval errors and collisions', async () => {
      // 1. Invalid time interval (start >= end)
      const invalidRes = await fetch(`${baseUrl}/timetable/validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${teacherToken}`,
        },
        body: JSON.stringify({
          day: 'Monday',
          startTime: '10:00',
          endTime: '09:00',
        }),
      });
      assert.strictEqual(invalidRes.status, 200);
      const invalidData = await invalidRes.json();
      assert.strictEqual(invalidData.valid, false);
      assert.strictEqual(invalidData.conflictCount, 1);

      // 2. Clean valid slot
      const cleanRes = await fetch(`${baseUrl}/timetable/validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${teacherToken}`,
        },
        body: JSON.stringify({
          day: 'Friday',
          startTime: '08:00',
          endTime: '09:00',
          teacherName: `Clean Teacher ${runId}`,
          room: `Clean Room ${runId}`,
        }),
      });
      assert.strictEqual(cleanRes.status, 200);
      const cleanData = await cleanRes.json();
      assert.strictEqual(cleanData.valid, true);
    });

    await t.test('POST /timetable creates initial slot and blocks overlapping collisions', async () => {
      // 1. Create base slot
      const baseRes = await fetch(`${baseUrl}/timetable`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          class: testClassA,
          day: 'Wednesday',
          subject: 'Quantum Physics',
          startTime: '09:00',
          endTime: '10:00',
          teacherName: testTeacher,
          room: testRoom,
        }),
      });
      assert.strictEqual(baseRes.status, 201);
      const baseData = await baseRes.json();
      createdIds.push(baseData.data.id);

      // 2. Attempt double-booking same teacher
      const teacherConflictRes = await fetch(`${baseUrl}/timetable`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          class: testClassB,
          day: 'Wednesday',
          subject: 'Astronomy',
          startTime: '09:30',
          endTime: '10:30',
          teacherName: testTeacher,
          room: `Diff-Room-${runId}`,
        }),
      });
      assert.strictEqual(teacherConflictRes.status, 409);
      const teacherConflictData = await teacherConflictRes.json();
      assert.match(teacherConflictData.message, /Timetable collision/i);

      // 3. Attempt double-booking same room
      const roomConflictRes = await fetch(`${baseUrl}/timetable`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          class: testClassC,
          day: 'Wednesday',
          subject: 'Geology',
          startTime: '09:15',
          endTime: '10:15',
          teacherName: `Other-Teacher-${runId}`,
          room: testRoom,
        }),
      });
      assert.strictEqual(roomConflictRes.status, 409);

      // 4. Override with allowConflict: true
      const overrideRes = await fetch(`${baseUrl}/timetable`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          class: testClassC,
          day: 'Wednesday',
          subject: 'Geology',
          startTime: '09:15',
          endTime: '10:15',
          teacherName: `Other-Teacher-${runId}`,
          room: testRoom,
          allowConflict: true,
        }),
      });
      assert.strictEqual(overrideRes.status, 201);
      const overrideData = await overrideRes.json();
      createdIds.push(overrideData.data.id);
    });

    await t.test('GET /timetable/workload/:teacherId returns workload metrics', async () => {
      const res = await fetch(`${baseUrl}/timetable/workload/${encodeURIComponent(testTeacher)}`, {
        headers: { Authorization: `Bearer ${teacherToken}` },
      });
      assert.strictEqual(res.status, 200);
      const body = await res.json();
      assert.strictEqual(body.success, true);
      assert.strictEqual(body.data.totalWeeklyPeriods >= 1, true);
      assert.strictEqual(body.data.totalHours >= 1.0, true);
      assert.strictEqual(body.data.dailyBreakdown.Wednesday >= 1, true);
    });

    await t.test('GET /timetable/conflicts returns existing collisions', async () => {
      const res = await fetch(`${baseUrl}/timetable/conflicts?day=Wednesday`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      assert.strictEqual(res.status, 200);
      const body = await res.json();
      assert.strictEqual(body.success, true);
      assert.strictEqual(body.count >= 1, true);
    });
  } finally {
    // Clean up created test entries
    for (const id of createdIds) {
      await fetch(`${baseUrl}/timetable/${id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${adminToken}` },
      }).catch(() => {});
    }
    server.close();
  }
});
