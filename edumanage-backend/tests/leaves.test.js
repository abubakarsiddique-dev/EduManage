const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

test('Leave Management API Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = '';
  let studentToken = '';
  let createdLeaveId = '';

  try {
    await t.test('Authenticate admin and student users', async () => {
      const adminRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'admin@edumanage.edu', password: 'Password@123' }),
      });
      assert.strictEqual(adminRes.status, 200);
      const adminData = await adminRes.json();
      adminToken = adminData.data.token;

      const studentRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: 'alex.johnson@edumanage.edu', password: 'Password@123' }),
      });
      assert.strictEqual(studentRes.status, 200);
      const studentData = await studentRes.json();
      studentToken = studentData.data.token;
    });

    await t.test('POST /leaves validates required fields and date order', async () => {
      // 1. Missing fields
      const missingRes = await fetch(`${baseUrl}/leaves`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({ reason: 'Vacation' }),
      });
      assert.strictEqual(missingRes.status, 400);

      // 2. Inverted dates: startDate > endDate
      const invertedRes = await fetch(`${baseUrl}/leaves`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({
          startDate: '2026-10-15',
          endDate: '2026-10-10',
          reason: 'Medical checkup',
        }),
      });
      assert.strictEqual(invertedRes.status, 400);
      const invertedData = await invertedRes.json();
      assert.strictEqual(invertedData.success, false);
    });

    await t.test('POST /leaves creates valid leave application in pending status', async () => {
      const res = await fetch(`${baseUrl}/leaves`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({
          startDate: '2026-10-10',
          endDate: '2026-10-12',
          leaveType: 'medical',
          reason: 'Severe flu recovery',
        }),
      });

      assert.strictEqual(res.status, 201);
      const data = await res.json();
      assert.strictEqual(data.success, true);
      assert.ok(data.data.id);
      createdLeaveId = data.data.id;
      assert.strictEqual(data.data.status, 'pending');
      assert.strictEqual(data.data.daysCount, 3); // Oct 10, 11, 12 = 3 days
    });

    await t.test('GET /leaves lists applications with filters', async () => {
      const res = await fetch(`${baseUrl}/leaves?status=pending`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });

      assert.strictEqual(res.status, 200);
      const data = await res.json();
      assert.ok(Array.isArray(data.data));
      const found = data.data.find(l => l.id === createdLeaveId);
      assert.ok(found);
    });

    await t.test('PATCH /leaves/:id/status allows teacher/admin to approve leave', async () => {
      const res = await fetch(`${baseUrl}/leaves/${createdLeaveId}/status`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          status: 'approved',
          reviewRemarks: 'Medical certificate verified. Approved.',
        }),
      });

      assert.strictEqual(res.status, 200);
      const data = await res.json();
      assert.strictEqual(data.data.status, 'approved');
      assert.strictEqual(data.data.reviewRemarks, 'Medical certificate verified. Approved.');
      assert.ok(data.data.reviewedBy);
    });

    await t.test('Role authorization: Student cannot approve their own leave', async () => {
      const res = await fetch(`${baseUrl}/leaves/${createdLeaveId}/status`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({
          status: 'approved',
        }),
      });

      assert.strictEqual(res.status, 403);
    });

    await t.test('GET /leaves/impact/:studentId computes projected attendance impact', async () => {
      const res = await fetch(`${baseUrl}/leaves/impact/student_001?proposedDays=4`, {
        headers: { Authorization: `Bearer ${studentToken}` },
      });

      assert.strictEqual(res.status, 200);
      const data = await res.json();
      assert.strictEqual(data.success, true);
      assert.ok(data.data.currentPercentage > 0);
      assert.ok(data.data.projectedPercentage > 0);
      assert.strictEqual(data.data.proposedLeaveDays, 4);
    });

    await t.test('DELETE /leaves/:id removes leave entry', async () => {
      const delRes = await fetch(`${baseUrl}/leaves/${createdLeaveId}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      assert.strictEqual(delRes.status, 200);

      const getRes = await fetch(`${baseUrl}/leaves/${createdLeaveId}`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      assert.strictEqual(getRes.status, 404);
    });
  } finally {
    server.close();
  }
});
