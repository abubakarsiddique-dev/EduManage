const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');
const {
  PERMISSIONS,
  getAllPermissions,
  getRolePermissions,
  getUserEffectivePermissions,
  hasPermission,
  hasAllPermissions,
  hasAnyPermission,
  setUserOverride,
  clearUserOverride,
  resetRbacState,
} = require('../src/modules/rbac/rbac.service');

test('RBAC Permission Matrix & Policy Enforcer Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = null;
  let teacherToken = null;
  let studentToken = null;

  try {
    // Setup authentication tokens
    await t.test('Acquire auth tokens for admin, teacher, and student', async () => {
      // Admin
      const adminRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'admin@edumanage.edu', password: 'Password@123' }),
      });
      assert.strictEqual(adminRes.status, 200);
      const adminData = await adminRes.json();
      adminToken = adminData.data.token;

      // Teacher
      const teacherRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'john.smith@edumanage.edu', password: 'Password@123' }),
      });
      assert.strictEqual(teacherRes.status, 200);
      const teacherData = await teacherRes.json();
      teacherToken = teacherData.data.token;

      // Student
      const studentRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'alex.johnson@edumanage.edu', password: 'Password@123' }),
      });
      assert.strictEqual(studentRes.status, 200);
      const studentData = await studentRes.json();
      studentToken = studentData.data.token;
    });

    // 1. Service unit tests
    await t.test('getAllPermissions returns full metadata catalog', () => {
      const perms = getAllPermissions();
      assert.ok(perms.length >= 15);
      assert.ok(perms.some((p) => p.id === PERMISSIONS.ATTENDANCE_MARK));
      assert.ok(perms.some((p) => p.id === PERMISSIONS.FEES_APPROVE));
    });

    await t.test('Role permissions adhere to least-privilege matrix', () => {
      const adminPerms = getRolePermissions('admin');
      const teacherPerms = getRolePermissions('teacher');
      const studentPerms = getRolePermissions('student');

      assert.ok(adminPerms.includes(PERMISSIONS.SYSTEM_BACKUP));
      assert.ok(teacherPerms.includes(PERMISSIONS.ATTENDANCE_MARK));
      assert.strictEqual(teacherPerms.includes(PERMISSIONS.SYSTEM_BACKUP), false);

      assert.ok(studentPerms.includes(PERMISSIONS.RESULTS_VIEW));
      assert.strictEqual(studentPerms.includes(PERMISSIONS.RESULTS_SUBMIT), false);
      assert.strictEqual(studentPerms.includes(PERMISSIONS.ATTENDANCE_MARK), false);
    });

    await t.test('hasPermission and hasAllPermissions evaluate correctly', () => {
      const teacherUser = { id: 'usr_t1', role: 'teacher' };
      const studentUser = { id: 'usr_s1', role: 'student' };
      const adminUser = { id: 'usr_a1', role: 'admin' };

      assert.strictEqual(hasPermission(teacherUser, PERMISSIONS.ATTENDANCE_MARK), true);
      assert.strictEqual(hasPermission(studentUser, PERMISSIONS.ATTENDANCE_MARK), false);
      assert.strictEqual(hasPermission(adminUser, PERMISSIONS.SYSTEM_BACKUP), true);

      assert.strictEqual(
        hasAllPermissions(teacherUser, [PERMISSIONS.ATTENDANCE_VIEW, PERMISSIONS.RESULTS_VIEW]),
        true
      );
      assert.strictEqual(
        hasAllPermissions(studentUser, [PERMISSIONS.RESULTS_VIEW, PERMISSIONS.RESULTS_SUBMIT]),
        false
      );
      assert.strictEqual(
        hasAnyPermission(studentUser, [PERMISSIONS.RESULTS_VIEW, PERMISSIONS.SYSTEM_BACKUP]),
        true
      );
    });

    await t.test('Custom user overrides grant and revoke specific permissions', () => {
      resetRbacState();
      const studentUser = { id: 'student_special_1', role: 'student' };

      // Baseline: student cannot mark attendance
      assert.strictEqual(hasPermission(studentUser, PERMISSIONS.ATTENDANCE_MARK), false);

      // Grant attendance:mark override
      setUserOverride('student_special_1', { grant: [PERMISSIONS.ATTENDANCE_MARK] });
      assert.strictEqual(hasPermission(studentUser, PERMISSIONS.ATTENDANCE_MARK), true);

      // Revoke results:view override
      setUserOverride('student_special_1', { revoke: [PERMISSIONS.RESULTS_VIEW] });
      assert.strictEqual(hasPermission(studentUser, PERMISSIONS.RESULTS_VIEW), false);

      // Clear override
      clearUserOverride('student_special_1');
      assert.strictEqual(hasPermission(studentUser, PERMISSIONS.ATTENDANCE_MARK), false);
      assert.strictEqual(hasPermission(studentUser, PERMISSIONS.RESULTS_VIEW), true);
    });

    // 2. Integration HTTP routes
    await t.test('GET /rbac/permissions returns permissions list', async () => {
      const res = await fetch(`${baseUrl}/rbac/permissions`);
      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.ok(json.count >= 15);
    });

    await t.test('GET /rbac/roles returns role definitions for authenticated users', async () => {
      const res = await fetch(`${baseUrl}/rbac/roles`, {
        headers: { Authorization: `Bearer ${teacherToken}` },
      });
      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.ok(json.roles.teacher.includes(PERMISSIONS.ATTENDANCE_MARK));
    });

    await t.test('POST /rbac/evaluate checks client permissions dynamically', async () => {
      const res = await fetch(`${baseUrl}/rbac/evaluate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({
          permissions: [PERMISSIONS.RESULTS_VIEW, PERMISSIONS.ATTENDANCE_MARK],
        }),
      });

      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.strictEqual(json.role, 'student');
      assert.strictEqual(json.allowed, false);
      assert.ok(json.missingPermissions.includes(PERMISSIONS.ATTENDANCE_MARK));
    });

    await t.test('POST /rbac/overrides permits admin and rejects non-admin users', async () => {
      // Non-admin attempt
      const studentAttempt = await fetch(`${baseUrl}/rbac/overrides`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({
          userId: 'test_user_override',
          grant: [PERMISSIONS.SYSTEM_BACKUP],
        }),
      });
      assert.strictEqual(studentAttempt.status, 403);

      // Admin attempt
      const adminAttempt = await fetch(`${baseUrl}/rbac/overrides`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          userId: 'test_user_override',
          grant: [PERMISSIONS.SYSTEM_BACKUP],
        }),
      });
      assert.strictEqual(adminAttempt.status, 200);
      const json = await adminAttempt.json();
      assert.strictEqual(json.success, true);
      assert.ok(json.override.granted.includes(PERMISSIONS.SYSTEM_BACKUP));
    });
  } finally {
    server.close();
  }
});
