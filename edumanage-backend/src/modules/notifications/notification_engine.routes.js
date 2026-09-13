const express = require('express');
const router = express.Router();
const { authenticate, authorizeRoles } = require('../../middleware/auth.middleware');
const {
  listTemplates,
  dispatchNotification,
  batchDispatch,
  getDispatchStats,
} = require('./notification_engine.service');

// All notification dispatch routes require authentication
router.use(authenticate);

/**
 * @route   GET /api/v1/notifications/templates
 * @desc    List available educational notification templates
 * @access  Authenticated (admin, teacher)
 */
router.get('/templates', authorizeRoles('admin', 'teacher'), (req, res) => {
  const templates = listTemplates();
  res.json({
    success: true,
    count: templates.length,
    data: templates,
  });
});

/**
 * @route   POST /api/v1/notifications/dispatch
 * @desc    Dispatch a single templated notification
 * @access  Authenticated (admin, teacher)
 */
router.post('/dispatch', authorizeRoles('admin', 'teacher'), (req, res, next) => {
  try {
    const { recipientId, templateKey, variables, channel, priority } = req.body;
    const record = dispatchNotification({
      recipientId,
      templateKey,
      variables,
      channel,
      priority,
      triggeredBy: req.user ? req.user.email || req.user.id : 'unknown',
    });

    res.status(201).json({
      success: true,
      message: 'Notification dispatched successfully',
      data: record,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * @route   POST /api/v1/notifications/batch-dispatch
 * @desc    Dispatch notifications to multiple recipients in batch
 * @access  Authenticated (admin, teacher)
 */
router.post('/batch-dispatch', authorizeRoles('admin', 'teacher'), (req, res, next) => {
  try {
    const { recipients, templateKey, commonVariables, channel } = req.body;
    const summary = batchDispatch({
      recipients,
      templateKey,
      commonVariables,
      channel,
      triggeredBy: req.user ? req.user.email || req.user.id : 'unknown',
    });

    res.status(201).json({
      success: true,
      message: `Batch dispatched: ${summary.dispatched} sent, ${summary.failed} failed`,
      data: summary,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * @route   GET /api/v1/notifications/stats
 * @desc    Retrieve aggregated delivery metrics and channel distribution
 * @access  Admin
 */
router.get('/stats', authorizeRoles('admin'), (req, res) => {
  const stats = getDispatchStats();
  res.json({
    success: true,
    data: stats,
  });
});

module.exports = router;
