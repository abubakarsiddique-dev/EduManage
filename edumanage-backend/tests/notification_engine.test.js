const test = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');
const {
  getTemplate,
  listTemplates,
  renderTemplate,
  dispatchNotification,
  batchDispatch,
  getDispatchStats,
  clearDispatchQueue,
} = require('../src/modules/notifications/notification_engine.service');

test('Notification Template & Dispatch Engine Suite', async (t) => {
  await app.initDb();

  const server = app.listen(0);
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  let adminToken = null;
  let studentToken = null;

  try {
    // 0. Setup authentication tokens
    await t.test('Authenticate admin and student roles', async () => {
      // Admin login
      const adminRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'admin@edumanage.edu',
          password: 'Password@123',
        }),
      });
      assert.strictEqual(adminRes.status, 200);
      const adminJson = await adminRes.json();
      adminToken = adminJson.data.token;

      // Student login
      const stuRes = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'alex.johnson@edumanage.edu',
          password: 'Password@123',
        }),
      });
      assert.strictEqual(stuRes.status, 200);
      const stuJson = await stuRes.json();
      studentToken = stuJson.data.token;
    });

    // 1. Unit: listTemplates & getTemplate
    await t.test('listTemplates returns standard educational templates', () => {
      const templates = listTemplates();
      assert.ok(templates.length >= 4);

      const feeTpl = getTemplate('FEE_DUE_REMINDER');
      assert.ok(feeTpl);
      assert.strictEqual(feeTpl.defaultPriority, 'high');
      assert.ok(feeTpl.channels.includes('EMAIL'));
    });

    // 2. Unit: renderTemplate interpolates variables and applies fallbacks
    await t.test('renderTemplate replaces placeholders correctly', () => {
      const rendered = renderTemplate('FEE_DUE_REMINDER', {
        studentName: 'Alex Morgan',
        amount: '450.00',
        className: 'Grade 10 - A',
        dueDate: '2026-09-30',
      });

      assert.strictEqual(rendered.title, 'Fee Due Reminder: Alex Morgan');
      assert.ok(rendered.body.includes('$450.00'));
      assert.ok(rendered.body.includes('Grade 10 - A'));
      assert.strictEqual(rendered.priority, 'high');

      // Missing variable fallback test
      const partial = renderTemplate('ATTENDANCE_ABSENT_ALERT', {
        studentName: 'Chris',
      });
      assert.ok(partial.body.includes('[className]'));
    });

    // 3. Unit: dispatchNotification & batchDispatch
    await t.test('dispatchNotification generates delivery records and tracks queue', () => {
      clearDispatchQueue();

      const record = dispatchNotification({
        recipientId: 'parent_001',
        templateKey: 'ASSIGNMENT_POSTED',
        variables: {
          subject: 'Science',
          title: 'Physics Lab Report',
          className: 'Grade 10',
          dueDate: '2026-09-20',
        },
        channel: 'EMAIL',
      });

      assert.ok(record.id.startsWith('notif_'));
      assert.strictEqual(record.status, 'DISPATCHED');
      assert.strictEqual(record.channel, 'EMAIL');

      const batch = batchDispatch({
        recipients: ['parent_002', 'parent_003'],
        templateKey: 'ATTENDANCE_ABSENT_ALERT',
        commonVariables: { className: 'Grade 10', date: '2026-09-13' },
      });

      assert.strictEqual(batch.total, 2);
      assert.strictEqual(batch.dispatched, 2);
      assert.strictEqual(batch.failed, 0);

      const stats = getDispatchStats();
      assert.strictEqual(stats.totalDispatched, 3);
      assert.strictEqual(stats.byTemplate.ATTENDANCE_ABSENT_ALERT, 2);
    });

    // 4. Integration: GET /api/v1/notifications/templates
    await t.test('GET /notifications/templates returns template catalog', async () => {
      const res = await fetch(`${baseUrl}/notifications/templates`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });

      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.ok(Array.isArray(json.data));
      assert.ok(json.count >= 4);
    });

    // 5. Integration: POST /api/v1/notifications/dispatch
    await t.test('POST /notifications/dispatch dispatches notification', async () => {
      const res = await fetch(`${baseUrl}/notifications/dispatch`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${adminToken}`,
        },
        body: JSON.stringify({
          recipientId: 'parent_100',
          templateKey: 'EXAM_RESULT_PUBLISHED',
          variables: {
            subject: 'Algebra',
            term: 'Midterm',
            studentName: 'Jessica',
            grade: 'A+',
            marks: 98,
          },
          channel: 'IN_APP',
        }),
      });

      assert.strictEqual(res.status, 201);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.strictEqual(json.data.status, 'DISPATCHED');
    });

    // 6. Integration: Access control - student cannot dispatch notifications
    await t.test('Student is forbidden from dispatching notifications', async () => {
      const res = await fetch(`${baseUrl}/notifications/dispatch`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${studentToken}`,
        },
        body: JSON.stringify({
          recipientId: 'parent_999',
          templateKey: 'FEE_DUE_REMINDER',
        }),
      });

      assert.strictEqual(res.status, 403);
    });

    // 7. Integration: GET /api/v1/notifications/stats
    await t.test('GET /notifications/stats returns aggregated metrics to admin', async () => {
      const res = await fetch(`${baseUrl}/notifications/stats`, {
        headers: { Authorization: `Bearer ${adminToken}` },
      });

      assert.strictEqual(res.status, 200);
      const json = await res.json();
      assert.strictEqual(json.success, true);
      assert.ok(json.data.totalDispatched >= 1);
    });
  } finally {
    clearDispatchQueue();
    server.close();
  }
});
