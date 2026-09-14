/**
 * Dynamic Role-Based Access Control (RBAC) Permission Matrix Service
 */

const PERMISSIONS = Object.freeze({
  STUDENTS_READ: 'students:read',
  STUDENTS_WRITE: 'students:write',
  TEACHERS_READ: 'teachers:read',
  TEACHERS_MANAGE: 'teachers:manage',
  CLASSES_READ: 'classes:read',
  CLASSES_MANAGE: 'classes:manage',
  ATTENDANCE_VIEW: 'attendance:view',
  ATTENDANCE_MARK: 'attendance:mark',
  FEES_VIEW: 'fees:view',
  FEES_MANAGE: 'fees:manage',
  FEES_APPROVE: 'fees:approve',
  RESULTS_VIEW: 'results:view',
  RESULTS_SUBMIT: 'results:submit',
  RESULTS_PUBLISH: 'results:publish',
  NOTICES_VIEW: 'notices:view',
  NOTICES_BROADCAST: 'notices:broadcast',
  SYSTEM_BACKUP: 'system:backup',
  AUDIT_VIEW: 'audit:view',
  RBAC_MANAGE: 'rbac:manage',
});

const PERMISSION_METADATA = [
  { id: PERMISSIONS.STUDENTS_READ, category: 'Students', description: 'View student profiles and academic history' },
  { id: PERMISSIONS.STUDENTS_WRITE, category: 'Students', description: 'Create, update, or enroll students' },
  { id: PERMISSIONS.TEACHERS_READ, category: 'Teachers', description: 'View teacher directories and profiles' },
  { id: PERMISSIONS.TEACHERS_MANAGE, category: 'Teachers', description: 'Approve, onboard, or modify teacher accounts' },
  { id: PERMISSIONS.CLASSES_READ, category: 'Classes', description: 'View classroom schedules and roster' },
  { id: PERMISSIONS.CLASSES_MANAGE, category: 'Classes', description: 'Create or reassign classes and streams' },
  { id: PERMISSIONS.ATTENDANCE_VIEW, category: 'Attendance', description: 'View attendance sheets and statistics' },
  { id: PERMISSIONS.ATTENDANCE_MARK, category: 'Attendance', description: 'Mark and submit daily classroom attendance' },
  { id: PERMISSIONS.FEES_VIEW, category: 'Finance', description: 'View tuition and fee invoice summaries' },
  { id: PERMISSIONS.FEES_MANAGE, category: 'Finance', description: 'Issue fee structures and custom invoices' },
  { id: PERMISSIONS.FEES_APPROVE, category: 'Finance', description: 'Verify payment proofs and reconcile accounts' },
  { id: PERMISSIONS.RESULTS_VIEW, category: 'Academics', description: 'View term grades and report cards' },
  { id: PERMISSIONS.RESULTS_SUBMIT, category: 'Academics', description: 'Submit subject scores and examination marks' },
  { id: PERMISSIONS.RESULTS_PUBLISH, category: 'Academics', description: 'Publish final grade sheets to students/parents' },
  { id: PERMISSIONS.NOTICES_VIEW, category: 'Communication', description: 'View announcements and school bulletins' },
  { id: PERMISSIONS.NOTICES_BROADCAST, category: 'Communication', description: 'Author and publish institutional notices' },
  { id: PERMISSIONS.SYSTEM_BACKUP, category: 'Administration', description: 'Create and verify snapshot system backups' },
  { id: PERMISSIONS.AUDIT_VIEW, category: 'Administration', description: 'Inspect administrative audit trails' },
  { id: PERMISSIONS.RBAC_MANAGE, category: 'Administration', description: 'Configure role permissions and user overrides' },
];

const DEFAULT_ROLE_PERMISSIONS = {
  admin: Object.values(PERMISSIONS),
  teacher: [
    PERMISSIONS.STUDENTS_READ,
    PERMISSIONS.TEACHERS_READ,
    PERMISSIONS.CLASSES_READ,
    PERMISSIONS.ATTENDANCE_VIEW,
    PERMISSIONS.ATTENDANCE_MARK,
    PERMISSIONS.RESULTS_VIEW,
    PERMISSIONS.RESULTS_SUBMIT,
    PERMISSIONS.NOTICES_VIEW,
    PERMISSIONS.NOTICES_BROADCAST,
    PERMISSIONS.FEES_VIEW,
  ],
  student: [
    PERMISSIONS.CLASSES_READ,
    PERMISSIONS.ATTENDANCE_VIEW,
    PERMISSIONS.RESULTS_VIEW,
    PERMISSIONS.NOTICES_VIEW,
    PERMISSIONS.FEES_VIEW,
  ],
  parent: [
    PERMISSIONS.CLASSES_READ,
    PERMISSIONS.ATTENDANCE_VIEW,
    PERMISSIONS.RESULTS_VIEW,
    PERMISSIONS.NOTICES_VIEW,
    PERMISSIONS.FEES_VIEW,
  ],
};

// In-memory overrides store for per-user custom permission grants and revocations
const userOverrides = new Map();

/**
 * Returns all permission definitions and metadata.
 */
const getAllPermissions = () => PERMISSION_METADATA;

/**
 * Returns default permissions array for a role.
 */
const getRolePermissions = (role) => {
  return DEFAULT_ROLE_PERMISSIONS[role] ? [...DEFAULT_ROLE_PERMISSIONS[role]] : [];
};

/**
 * Computes the effective set of permissions for a user, taking into account
 * their role and any user-level custom grants or revocations.
 */
const getUserEffectivePermissions = (user) => {
  if (!user || !user.role) return [];

  // Super-admin role always possesses all permissions
  if (user.role === 'admin') {
    return Object.values(PERMISSIONS);
  }

  const rolePerms = new Set(getRolePermissions(user.role));
  const userId = user.id || user.uid;

  if (userId && userOverrides.has(userId)) {
    const override = userOverrides.get(userId);
    if (override.granted) {
      override.granted.forEach((p) => rolePerms.add(p));
    }
    if (override.revoked) {
      override.revoked.forEach((p) => rolePerms.delete(p));
    }
  }

  return Array.from(rolePerms);
};

/**
 * Checks if a user has a specific permission.
 */
const hasPermission = (user, requiredPermission) => {
  if (!user || !user.role) return false;
  if (user.role === 'admin') return true;

  const effective = getUserEffectivePermissions(user);
  if (effective.includes(requiredPermission)) return true;

  // Support domain wildcard matching, e.g. "students:*" matches "students:read"
  const [domain] = requiredPermission.split(':');
  if (effective.includes(`${domain}:*`)) return true;

  return false;
};

/**
 * Checks if a user satisfies ALL of the specified permissions.
 */
const hasAllPermissions = (user, requiredPermissions) => {
  if (!Array.isArray(requiredPermissions) || requiredPermissions.length === 0) return true;
  return requiredPermissions.every((perm) => hasPermission(user, perm));
};

/**
 * Checks if a user satisfies AT LEAST ONE of the specified permissions.
 */
const hasAnyPermission = (user, requiredPermissions) => {
  if (!Array.isArray(requiredPermissions) || requiredPermissions.length === 0) return true;
  return requiredPermissions.some((perm) => hasPermission(user, perm));
};

/**
 * Sets user-specific grants and revocations.
 */
const setUserOverride = (userId, { grant = [], revoke = [] }) => {
  const current = userOverrides.get(userId) || { granted: new Set(), revoked: new Set() };

  grant.forEach((p) => {
    current.granted.add(p);
    current.revoked.delete(p);
  });

  revoke.forEach((p) => {
    current.revoked.add(p);
    current.granted.delete(p);
  });

  userOverrides.set(userId, current);

  return {
    userId,
    granted: Array.from(current.granted),
    revoked: Array.from(current.revoked),
  };
};

/**
 * Clears overrides for a user.
 */
const clearUserOverride = (userId) => {
  return userOverrides.delete(userId);
};

/**
 * Resets state for testing.
 */
const resetRbacState = () => {
  userOverrides.clear();
};

module.exports = {
  PERMISSIONS,
  PERMISSION_METADATA,
  DEFAULT_ROLE_PERMISSIONS,
  getAllPermissions,
  getRolePermissions,
  getUserEffectivePermissions,
  hasPermission,
  hasAllPermissions,
  hasAnyPermission,
  setUserOverride,
  clearUserOverride,
  resetRbacState,
};
