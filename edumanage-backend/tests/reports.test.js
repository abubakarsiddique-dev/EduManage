const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

test('Institutional Reporting & Performance Analytics API Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = null;
  let teacherToken = null;
  let studentToken = null;

  try {
    // 0. Setup authentication tokens
    await t.test('Authenticate admin, teacher, and student', async () => {
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

    // 1. HTTP Endpoint Tests
    await t.test('GET /reports/academic returns aggregated academic metrics to admin & teacher', async () => {
      const res = await fetch(`${baseUrl}/reports/academic`, {
        headers: { Authorization: `Bearer ${teacherToken}` },
      });
      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.strictEqual(json.reportType, 'ACADEMIC_PERFORMANCE_SUMMARY');
      assert.ok(json.data.totalEvaluated >= 1);
      assert.ok(json.data.averageScore > 0);
      assert.ok(json.data.passRatePercentage >= 0);
      assert.ok(json.data.highestScore >= 0);
      assert.ok(json.data.topPerformers.length >= 1);
      assert.ok(json.data.gradeDistribution);
    });

    await t.test('GET /reports/attendance calculates presence rates and class breakdowns', async () => {
      const res = await fetch(`${baseUrl}/reports/attendance`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.strictEqual(json.reportType, 'ATTENDANCE_OVERVIEW_SUMMARY');
      assert.ok(json.data.totalRecords >= 1);
      assert.ok(json.data.overallAttendanceRate >= 0);
      assert.ok(Array.isArray(json.data.byClass));
      assert.ok(Array.isArray(json.data.chronicAbsenteeism));
    });

    await t.test('GET /reports/financial computes invoice reconciliation for admin', async () => {
      const res = await fetch(`${baseUrl}/reports/financial`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.strictEqual(json.reportType, 'FINANCIAL_RECONCILIATION_REPORT');
      assert.ok(json.data.totalInvoiced >= 1000.0);
      assert.ok(json.data.totalCollected >= 1000.0);
      assert.ok(json.data.collectionEfficiencyPercentage > 0);
      assert.ok(json.data.byStatus.paid.count >= 1);
      assert.ok(json.data.byFeeType.length >= 1);
    });

    await t.test('Role authorization: Student is forbidden from all report endpoints', async () => {
      const academicRes = await fetch(`${baseUrl}/reports/academic`, {
        headers: { Authorization: `Bearer ${studentToken}` },
      });
      assert.strictEqual(academicRes.status, 403);

      const attendanceRes = await fetch(`${baseUrl}/reports/attendance`, {
        headers: { Authorization: `Bearer ${studentToken}` },
      });
      assert.strictEqual(attendanceRes.status, 403);

      const financialRes = await fetch(`${baseUrl}/reports/financial`, {
        headers: { Authorization: `Bearer ${studentToken}` },
      });
      assert.strictEqual(financialRes.status, 403);
    });

    await t.test('Role authorization: Teacher is forbidden from financial reports', async () => {
      const res = await fetch(`${baseUrl}/reports/financial`, {
        headers: { Authorization: `Bearer ${teacherToken}` },
      });
      assert.strictEqual(res.status, 403);
    });

    await t.test('Unauthenticated request is rejected with 401', async () => {
      const res = await fetch(`${baseUrl}/reports/academic`);
      assert.strictEqual(res.status, 401);
    });
  } finally {
    server.close();
  }
});
