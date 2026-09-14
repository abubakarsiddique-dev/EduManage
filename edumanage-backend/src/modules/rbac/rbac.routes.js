const express = require('express');
const router = express.Router();
const { authenticate, authorizeRoles } = require('../../middleware/auth.middleware');
const { requirePermissions } = require('../../middleware/rbac.middleware');
const rbacService = require('./rbac.service');

// Public/authenticated: List all system permissions and catalog
router.get('/permissions', (req, res) => {
  res.json({
    success: true,
    count: rbacService.getAllPermissions().length,
    permissions: rbacService.getAllPermissions(),
  });
});

// Authenticated: List default role-to-permission mappings
router.get('/roles', authenticate, (req, res) => {
  res.json({
    success: true,
    roles: {
      admin: rbacService.getRolePermissions('admin'),
      teacher: rbacService.getRolePermissions('teacher'),
      student: rbacService.getRolePermissions('student'),
      parent: rbacService.getRolePermissions('parent'),
    },
  });
});

// Authenticated: Evaluate user's own permissions or tested permissions
router.post('/evaluate', authenticate, (req, res) => {
  const { permissions = [] } = req.body;
  const effective = rbacService.getUserEffectivePermissions(req.user);

  let allowed = true;
  let missing = [];

  if (Array.isArray(permissions) && permissions.length > 0) {
    allowed = rbacService.hasAllPermissions(req.user, permissions);
    missing = permissions.filter((p) => !rbacService.hasPermission(req.user, p));
  }

  res.json({
    success: true,
    role: req.user.role,
    allowed,
    effectivePermissions: effective,
    missingPermissions: missing,
  });
});

// Admin only: Configure custom user permission override
router.post(
  '/overrides',
  authenticate,
  authorizeRoles('admin'),
  (req, res) => {
    const { userId, grant = [], revoke = [] } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'userId is required to configure permission overrides',
      });
    }

    const result = rbacService.setUserOverride(userId, { grant, revoke });

    res.status(200).json({
      success: true,
      message: `Permission overrides updated for user ${userId}`,
      override: result,
    });
  }
);

// Admin only: Clear custom user permission override
router.delete(
  '/overrides/:userId',
  authenticate,
  authorizeRoles('admin'),
  (req, res) => {
    const { userId } = req.params;
    const removed = rbacService.clearUserOverride(userId);

    res.status(200).json({
      success: true,
      message: removed
        ? `Permission overrides cleared for user ${userId}`
        : `No overrides existed for user ${userId}`,
    });
  }
);

module.exports = router;
