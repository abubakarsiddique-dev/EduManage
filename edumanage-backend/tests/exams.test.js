const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

test('Exam Management & Curving API Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = '';
  let studentToken = '';
  let createdExamId = '';

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

    await t.test('POST /exams validates required fields', async () => {
      const res = await fetch(`${baseUrl}/exams`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          title: 'Physics Midterm',
          // missing classId, subject, maxScore
        }),
      });

      assert.strictEqual(res.status, 400);
      const data = await res.json();
      assert.strictEqual(data.success, false);
    });

    await t.test('POST /exams successfully creates scheduled exam', async () => {
      const res = await fetch(`${baseUrl}/exams`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          title: 'Midterm Physics 101',
          classId: 'cls_grade10',
          subject: 'Physics',
          term: 'Term 1',
          date: '2026-10-15',
          durationMinutes: 90,
          maxScore: 100,
          passingScore: 50,
        }),
      });

      assert.strictEqual(res.status, 201);
      const data = await res.json();
      assert.strictEqual(data.success, true);
      assert.ok(data.data.id);
      createdExamId = data.data.id;
      assert.strictEqual(data.data.title, 'Midterm Physics 101');
      assert.strictEqual(data.data.maxScore, 100);
    });

    await t.test('POST /exams/:id/grades submits student scores with boundary checks', async () => {
      // 1. Invalid grade > maxScore
      const invalidRes = await fetch(`${baseUrl}/exams/${createdExamId}/grades`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          grades: [{ studentId: 'std_01', studentName: 'Alex', score: 150 }],
        }),
      });
      assert.strictEqual(invalidRes.status, 400);

      // 2. Valid batch of scores
      const validRes = await fetch(`${baseUrl}/exams/${createdExamId}/grades`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          grades: [
            { studentId: 'std_01', studentName: 'Alex', score: 85 },
            { studentId: 'std_02', studentName: 'Beth', score: 72 },
            { studentId: 'std_03', studentName: 'Charlie', score: 45 },
            { studentId: 'std_04', studentName: 'Diana', score: 92 },
            { studentId: 'std_05', studentName: 'Evan', score: 38 },
          ],
        }),
      });

      assert.strictEqual(validRes.status, 200);
      const validData = await validRes.json();
      assert.strictEqual(validData.data.grades.length, 5);
      assert.strictEqual(validData.data.status, 'evaluated');
    });

    await t.test('POST /exams/:id/curve produces preview curve models', async () => {
      // Anchor to max
      const curveRes = await fetch(`${baseUrl}/exams/${createdExamId}/curve`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          strategy: 'anchorToMax',
          targetMax: 100,
        }),
      });

      assert.strictEqual(curveRes.status, 200);
      const curveData = await curveRes.json();
      assert.strictEqual(curveData.success, true);
      assert.strictEqual(curveData.data.curvedGrades.length, 5);

      // Highest score was 92, should be scaled to 100
      const highest = curveData.data.curvedGrades.find(g => g.rawScore === 92);
      assert.strictEqual(highest.curvedPercentage, 100);
    });

    await t.test('GET /exams/:id/statistics computes summary statistics', async () => {
      const statsRes = await fetch(`${baseUrl}/exams/${createdExamId}/statistics`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });

      assert.strictEqual(statsRes.status, 200);
      const statsData = await statsRes.json();
      assert.strictEqual(statsData.data.totalSubmissions, 5);
      assert.strictEqual(statsData.data.highestScore, 92);
      assert.strictEqual(statsData.data.lowestScore, 38);
      assert.strictEqual(statsData.data.passingCount, 3); // 85, 72, 92 >= 50
      assert.strictEqual(statsData.data.passingRate, 60);
    });

    await t.test('Role authorization: Student cannot create or curve exams', async () => {
      const studentCreateRes = await fetch(`${baseUrl}/exams`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({
          title: 'Unauthorized Exam',
          classId: 'cls_1',
          subject: 'Math',
          maxScore: 100,
        }),
      });
      assert.strictEqual(studentCreateRes.status, 403);

      const studentCurveRes = await fetch(`${baseUrl}/exams/${createdExamId}/curve`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({ strategy: 'squareRoot' }),
      });
      assert.strictEqual(studentCurveRes.status, 403);
    });

    await t.test('DELETE /exams/:id removes exam record', async () => {
      const delRes = await fetch(`${baseUrl}/exams/${createdExamId}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      assert.strictEqual(delRes.status, 200);

      const getRes = await fetch(`${baseUrl}/exams/${createdExamId}`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });
      assert.strictEqual(getRes.status, 404);
    });
  } finally {
    server.close();
  }
});
