const { AppError } = require('./error.middleware');
const { recordAuditEvent } = require('./audit.middleware');
const rbacService = require('../modules/rbac/rbac.service');

/**
 * Middleware enforcing granular RBAC permission requirements.
 *
 * @param {string|string[]} permissions - Required permission key(s)
 * @param {Object} [options]
 * @param {'all'|'any'} [options.mode='all'] - Whether all or any permission must match
 */
const requirePermissions = (permissions, options = {}) => {
  const permsList = Array.isArray(permissions) ? permissions : [permissions];
  const mode = options.mode || 'all';

  return (req, res, next) => {
    if (!req.user || !req.user.role) {
      return next(new AppError('Authentication required. Missing user session.', 401));
    }

    const isAuthorized =
      mode === 'any'
        ? rbacService.hasAnyPermission(req.user, permsList)
        : rbacService.hasAllPermissions(req.user, permsList);

    const effective = rbacService.getUserEffectivePermissions(req.user);
    req.user.effectivePermissions = effective;

    if (!isAuthorized) {
      const missing = permsList.filter((p) => !rbacService.hasPermission(req.user, p));

      // Audit trail record for denied attempt
      recordAuditEvent({
        action: 'RBAC_ACCESS_DENIED',
        actor: req.user,
        resource: req.originalUrl || req.url,
        method: req.method,
        statusCode: 403,
        ip: req.ip || req.connection.remoteAddress || '127.0.0.1',
        details: {
          required: permsList,
          mode,
          missing,
        },
      });

      return next(
        new AppError(
          `Forbidden: User lacks required permission(s): ${missing.join(', ')}`,
          403
        )
      );
    }

    next();
  };
};

module.exports = {
  requirePermissions,
};
