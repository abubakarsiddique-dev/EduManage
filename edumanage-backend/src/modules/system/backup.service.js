const crypto = require('crypto');
const defaultDb = require('../../db/store');
const { AppError } = require('../../middleware/error.middleware');

// In-memory snapshots registry with retention limit
const MAX_SNAPSHOTS = 20;
let snapshotsRegistry = [];

/**
 * Recursively produces deterministic JSON representation with sorted keys.
 */
const deterministicStringify = (obj) => {
  if (obj === null || typeof obj !== 'object') {
    return JSON.stringify(obj);
  }
  if (Array.isArray(obj)) {
    return `[${obj.map(deterministicStringify).join(',')}]`;
  }
  const sortedKeys = Object.keys(obj).sort();
  return `{${sortedKeys.map((k) => `${JSON.stringify(k)}:${deterministicStringify(obj[k])}`).join(',')}}`;
};

/**
 * Computes a deterministic SHA-256 hash for a given object data.
 *
 * @param {Object} data - Database collection payload
 * @returns {string} SHA-256 hex string prefixed with 'sha256:'
 */
const computeChecksum = (data) => {
  const serialized = deterministicStringify(data);
  const hash = crypto.createHash('sha256').update(serialized).digest('hex');
  return `sha256:${hash}`;
};

/**
 * Creates an immutable point-in-time snapshot of all database collections with cryptographic checksum.
 *
 * @param {Object} options - Metadata options (reason, triggeredBy)
 * @param {Object} db - Database store instance
 * @returns {Object} Newly created snapshot object
 */
const createSnapshot = (options = {}, db = defaultDb) => {
  const { reason = 'Routine system snapshot', triggeredBy = 'system' } = options;

  // Clone database collections deeply
  const collectionsCopy = JSON.parse(JSON.stringify(db.collections || {}));

  const collectionStats = {};
  let totalRecords = 0;

  for (const [name, records] of Object.entries(collectionsCopy)) {
    if (Array.isArray(records)) {
      collectionStats[name] = records.length;
      totalRecords += records.length;
    }
  }

  const checksum = computeChecksum(collectionsCopy);
  const now = new Date();
  const snapshotId = `snap_${now.getTime()}_${crypto.randomBytes(4).toString('hex')}`;

  const snapshot = {
    id: snapshotId,
    timestamp: now.toISOString(),
    version: '1.5.0',
    reason,
    triggeredBy,
    checksum,
    stats: {
      totalRecords,
      collections: collectionStats,
    },
    data: collectionsCopy,
  };

  // Prepend to registry and prune old snapshots beyond retention limit
  snapshotsRegistry.unshift(snapshot);
  if (snapshotsRegistry.length > MAX_SNAPSHOTS) {
    snapshotsRegistry.pop();
  }

  return snapshot;
};

/**
 * Validates the cryptographic checksum and schema of a database snapshot.
 *
 * @param {Object} snapshot - The snapshot object to verify
 * @returns {Object} Verification diagnostic report
 */
const verifySnapshot = (snapshot) => {
  if (!snapshot || typeof snapshot !== 'object') {
    return { valid: false, error: 'Snapshot payload must be a non-null object' };
  }

  if (!snapshot.id || !snapshot.checksum || !snapshot.data) {
    return { valid: false, error: 'Missing required snapshot fields (id, checksum, or data)' };
  }

  const recalculated = computeChecksum(snapshot.data);
  const isValid = recalculated === snapshot.checksum;

  return {
    valid: isValid,
    snapshotId: snapshot.id,
    expectedChecksum: snapshot.checksum,
    recalculatedChecksum: recalculated,
    ...(isValid ? {} : { error: 'Checksum mismatch detected: snapshot data may be corrupted or tampered with' }),
  };
};

/**
 * Atomically restores the database collections from a verified snapshot.
 *
 * @param {string|Object} snapshotOrId - Snapshot ID or snapshot object
 * @param {Object} db - Database store instance
 * @returns {Object} Restoration summary
 */
const restoreSnapshot = (snapshotOrId, db = defaultDb) => {
  let targetSnapshot = null;

  if (typeof snapshotOrId === 'string') {
    targetSnapshot = snapshotsRegistry.find((s) => s.id === snapshotOrId);
    if (!targetSnapshot) {
      throw new AppError(`Snapshot with ID '${snapshotOrId}' not found`, 404);
    }
  } else if (snapshotOrId && typeof snapshotOrId === 'object') {
    targetSnapshot = snapshotOrId;
  } else {
    throw new AppError('Invalid snapshot identifier provided for restore', 400);
  }

  // Cryptographic integrity validation before restoration
  const verification = verifySnapshot(targetSnapshot);
  if (!verification.valid) {
    throw new AppError(`Snapshot integrity verification failed: ${verification.error}`, 400);
  }

  // Restore collections
  db.collections = JSON.parse(JSON.stringify(targetSnapshot.data));
  if (typeof db._save === 'function') {
    db._save();
  }

  return {
    restored: true,
    snapshotId: targetSnapshot.id,
    timestamp: targetSnapshot.timestamp,
    restoredCollections: Object.keys(targetSnapshot.data),
    totalRecords: targetSnapshot.stats ? targetSnapshot.stats.totalRecords : 0,
  };
};

/**
 * Returns a list of snapshot metadata records (excluding heavy raw data payloads).
 *
 * @returns {Array<Object>} Snapshot metadata records
 */
const listSnapshots = () => {
  return snapshotsRegistry.map(({ data, ...meta }) => meta);
};

/**
 * Retrieves a snapshot by ID including data.
 *
 * @param {string} id - Snapshot ID
 * @returns {Object|null}
 */
const getSnapshotById = (id) => {
  return snapshotsRegistry.find((s) => s.id === id) || null;
};

/**
 * Clears the in-memory snapshots registry (for testing purposes).
 */
const clearSnapshotsRegistry = () => {
  snapshotsRegistry = [];
};

module.exports = {
  createSnapshot,
  verifySnapshot,
  restoreSnapshot,
  listSnapshots,
  getSnapshotById,
  computeChecksum,
  clearSnapshotsRegistry,
};
