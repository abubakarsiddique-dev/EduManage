const express = require('express');
const router = express.Router();
const { authenticate, authorizeRoles } = require('../../middleware/auth.middleware');
const {
  createSnapshot,
  verifySnapshot,
  restoreSnapshot,
  listSnapshots,
  getSnapshotById,
} = require('./backup.service');

// All backup management endpoints are restricted to authenticated system administrators
router.use(authenticate, authorizeRoles('admin'));

/**
 * @route   GET /api/v1/system/backups
 * @desc    List all recent database snapshots and checksum metadata
 * @access  Admin
 */
router.get('/', (req, res) => {
  const snapshots = listSnapshots();
  res.json({
    success: true,
    count: snapshots.length,
    data: snapshots,
  });
});

/**
 * @route   POST /api/v1/system/backups
 * @desc    Trigger immediate creation of a point-in-time database snapshot
 * @access  Admin
 */
router.post('/', (req, res) => {
  const { reason } = req.body;
  const snapshot = createSnapshot({
    reason: reason || 'Manual administrative backup',
    triggeredBy: req.user ? req.user.email || req.user.id : 'admin',
  });

  res.status(201).json({
    success: true,
    message: 'System snapshot generated successfully',
    data: snapshot,
  });
});

/**
 * @route   GET /api/v1/system/backups/:id
 * @desc    Retrieve full snapshot including database records
 * @access  Admin
 */
router.get('/:id', (req, res) => {
  const snapshot = getSnapshotById(req.params.id);
  if (!snapshot) {
    return res.status(404).json({
      success: false,
      message: `Snapshot '${req.params.id}' not found`,
    });
  }

  res.json({
    success: true,
    data: snapshot,
  });
});

/**
 * @route   POST /api/v1/system/backups/verify
 * @desc    Verify the cryptographic checksum and schema of a snapshot
 * @access  Admin
 */
router.post('/verify', (req, res) => {
  const { snapshot } = req.body;
  const result = verifySnapshot(snapshot);

  res.json({
    success: result.valid,
    report: result,
  });
});

/**
 * @route   POST /api/v1/system/backups/restore
 * @desc    Restore database state from a verified snapshot
 * @access  Admin
 */
router.post('/restore', (req, res, next) => {
  try {
    const { snapshotId, snapshot } = req.body;
    const identifier = snapshotId || snapshot;
    const result = restoreSnapshot(identifier);

    res.json({
      success: true,
      message: 'Database state restored successfully from snapshot',
      data: result,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
