const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

test('Batch Student Admission & Bulk Ingestion API Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = null;
  let teacherToken = null;
  const runId = Date.now();
  const createdStudentIds = [];

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

    await t.test('Role authorization: Teacher is forbidden from bulk endpoints', async () => {
      const validateRes = await fetch(`${baseUrl}/students/bulk-validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${teacherToken}`,
        },
        body: JSON.stringify({ students: [] }),
      });
      assert.strictEqual(validateRes.status, 403);

      const enrollRes = await fetch(`${baseUrl}/students/bulk-enroll`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${teacherToken}`,
        },
        body: JSON.stringify({ students: [] }),
      });
      assert.strictEqual(enrollRes.status, 403);
    });

    await t.test('POST /students/bulk-validate validates schema and detects conflicts', async () => {
      // 1. Rejects empty payload
      const emptyRes = await fetch(`${baseUrl}/students/bulk-validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({ students: [] }),
      });
      assert.strictEqual(emptyRes.status, 400);

      // 2. Detects invalid emails, duplicates, and missing fields
      const invalidRes = await fetch(`${baseUrl}/students/bulk-validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          students: [
            { name: '', email: 'not-an-email', class: 'Grade 9 - A' }, // Missing name, invalid email
            { name: 'Student Two', email: `dup.${runId}@edumanage.edu`, class: 'Grade 9 - A', rollNo: '101' },
            { name: 'Student Three', email: `dup.${runId}@edumanage.edu`, class: 'Grade 9 - A', rollNo: '101' }, // Duplicate email & roll
          ],
        }),
      });
      assert.strictEqual(invalidRes.status, 200);
      const report = await invalidRes.json();
      assert.strictEqual(report.success, true);
      assert.strictEqual(report.data.isValid, false);
      assert.strictEqual(report.data.errorCount >= 2, true);

      // 3. Valid batch
      const validRes = await fetch(`${baseUrl}/students/bulk-validate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          students: [
            { name: 'Alice Test', email: `alice.${runId}@edumanage.edu`, class: 'Grade 10 - A', rollNo: `R1-${runId}` },
            { name: 'Bob Test', email: `bob.${runId}@edumanage.edu`, class: 'Grade 10 - A', rollNo: `R2-${runId}` },
          ],
        }),
      });
      assert.strictEqual(validRes.status, 200);
      const validReport = await validRes.json();
      assert.strictEqual(validReport.data.isValid, true);
      assert.strictEqual(validReport.data.validCount, 2);
    });

    await t.test('POST /students/bulk-enroll aborts entire batch on atomic failure', async () => {
      const atomicFailRes = await fetch(`${baseUrl}/students/bulk-enroll`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          atomic: true,
          students: [
            { name: 'Charlie Clean', email: `charlie.${runId}@edumanage.edu`, class: 'Grade 10 - B' },
            { name: '', email: 'bad-email', class: 'Grade 10 - B' }, // Triggers failure
          ],
        }),
      });
      assert.strictEqual(atomicFailRes.status, 422);

      // Verify Charlie was NOT enrolled due to rollback
      const searchRes = await fetch(`${baseUrl}/students?search=Charlie`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      const searchData = await searchRes.json();
      const charlieFound = searchData.data.find((s) => s.email === `charlie.${runId}@edumanage.edu`);
      assert.strictEqual(charlieFound, undefined);
    });

    await t.test('POST /students/bulk-enroll successfully enrolls batch and supports partial mode', async () => {
      // 1. Atomic successful enrollment
      const enrollRes = await fetch(`${baseUrl}/students/bulk-enroll`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          atomic: true,
          students: [
            { name: `Batch Student A ${runId}`, email: `stdA.${runId}@edumanage.edu`, class: 'Grade 10 - C', rollNo: `A-${runId}` },
            { name: `Batch Student B ${runId}`, email: `stdB.${runId}@edumanage.edu`, class: 'Grade 10 - C', rollNo: `B-${runId}` },
          ],
        }),
      });
      assert.strictEqual(enrollRes.status, 201);
      const enrollData = await enrollRes.json();
      assert.strictEqual(enrollData.data.enrolledCount, 2);
      enrollData.data.enrolled.forEach((s) => createdStudentIds.push(s.id));

      // 2. Partial best-effort mode
      const partialRes = await fetch(`${baseUrl}/students/bulk-enroll`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          atomic: false,
          students: [
            { name: `Batch Student C ${runId}`, email: `stdC.${runId}@edumanage.edu`, class: 'Grade 10 - C', rollNo: `C-${runId}` },
            { name: '', email: 'invalid', class: 'Grade 10 - C' }, // Should fail
          ],
        }),
      });
      assert.strictEqual(partialRes.status, 201);
      const partialData = await partialRes.json();
      assert.strictEqual(partialData.data.enrolledCount, 1);
      assert.strictEqual(partialData.data.failedCount, 1);
      partialData.data.enrolled.forEach((s) => createdStudentIds.push(s.id));
    });
  } finally {
    // Teardown created students
    for (const id of createdStudentIds) {
      await fetch(`${baseUrl}/students/${id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${adminToken}` },
      }).catch(() => {});
    }
    server.close();
  }
});
