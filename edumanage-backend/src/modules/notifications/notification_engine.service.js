const crypto = require('crypto');
const { AppError } = require('../../middleware/error.middleware');

// Standardized educational notification templates
const TEMPLATE_CATALOG = {
  FEE_DUE_REMINDER: {
    key: 'FEE_DUE_REMINDER',
    title: 'Fee Due Reminder: {{studentName}}',
    body: 'Dear Parent, the outstanding fee of ${{amount}} for {{studentName}} (Class {{className}}) is due on {{dueDate}}. Please settle promptly.',
    channels: ['IN_APP', 'EMAIL', 'SMS'],
    defaultPriority: 'high',
    requiredVariables: ['studentName', 'amount', 'className', 'dueDate'],
  },
  ASSIGNMENT_POSTED: {
    key: 'ASSIGNMENT_POSTED',
    title: 'New Assignment: {{subject}} - {{title}}',
    body: 'A new assignment "{{title}}" for {{subject}} has been published for Class {{className}}. Submission deadline: {{dueDate}}.',
    channels: ['IN_APP', 'EMAIL'],
    defaultPriority: 'medium',
    requiredVariables: ['subject', 'title', 'className', 'dueDate'],
  },
  ATTENDANCE_ABSENT_ALERT: {
    key: 'ATTENDANCE_ABSENT_ALERT',
    title: 'Attendance Alert: {{studentName}} Absent',
    body: 'Please be informed that {{studentName}} was marked absent for Class {{className}} on {{date}}.',
    channels: ['IN_APP', 'SMS'],
    defaultPriority: 'high',
    requiredVariables: ['studentName', 'className', 'date'],
  },
  EXAM_RESULT_PUBLISHED: {
    key: 'EXAM_RESULT_PUBLISHED',
    title: 'Exam Result Published: {{subject}}',
    body: 'The examination result for {{subject}} ({{term}}) has been recorded for {{studentName}}. Grade achieved: {{grade}} ({{marks}}%).',
    channels: ['IN_APP', 'EMAIL'],
    defaultPriority: 'normal',
    requiredVariables: ['subject', 'term', 'studentName', 'grade', 'marks'],
  },
};

// In-memory dispatched notifications queue with retention limit
const MAX_DISPATCH_HISTORY = 100;
let dispatchHistory = [];

/**
 * Returns the template definition for [templateKey] or null if not found.
 */
const getTemplate = (templateKey) => {
  return TEMPLATE_CATALOG[templateKey] || null;
};

/**
 * Returns all available notification templates.
 */
const listTemplates = () => {
  return Object.values(TEMPLATE_CATALOG);
};

/**
 * Interpolates variables into a template string replacing {{key}}.
 */
const interpolate = (text, variables = {}) => {
  return text.replace(/\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/g, (_, key) => {
    return variables[key] !== undefined && variables[key] !== null
      ? String(variables[key])
      : `[${key}]`;
  });
};

/**
 * Renders a template into a concrete title and body.
 */
const renderTemplate = (templateKey, variables = {}) => {
  const template = getTemplate(templateKey);
  if (!template) {
    throw new AppError(`Notification template '${templateKey}' not found`, 404);
  }

  const renderedTitle = interpolate(template.title, variables);
  const renderedBody = interpolate(template.body, variables);

  return {
    templateKey,
    title: renderedTitle,
    body: renderedBody,
    priority: variables.priority || template.defaultPriority,
    supportedChannels: template.channels,
  };
};

/**
 * Dispatches an individual notification record to a recipient.
 */
const dispatchNotification = (options = {}) => {
  const {
    recipientId,
    templateKey,
    variables = {},
    channel = 'IN_APP',
    priority,
    triggeredBy = 'system',
  } = options;

  if (!recipientId) {
    throw new AppError('Recipient ID is required for notification dispatch', 400);
  }

  const rendered = renderTemplate(templateKey, variables);

  const deliveryRecord = {
    id: `notif_${Date.now()}_${crypto.randomBytes(3).toString('hex')}`,
    recipientId,
    templateKey,
    title: rendered.title,
    body: rendered.body,
    channel,
    priority: priority || rendered.priority,
    status: 'DISPATCHED',
    dispatchedAt: new Date().toISOString(),
    triggeredBy,
  };

  dispatchHistory.unshift(deliveryRecord);
  if (dispatchHistory.length > MAX_DISPATCH_HISTORY) {
    dispatchHistory.pop();
  }

  return deliveryRecord;
};

/**
 * Performs batch dispatch of notifications across multiple recipients.
 */
const batchDispatch = (options = {}) => {
  const {
    recipients = [],
    templateKey,
    commonVariables = {},
    channel = 'IN_APP',
    triggeredBy = 'system',
  } = options;

  if (!Array.isArray(recipients) || recipients.length === 0) {
    throw new AppError('Recipients list must be a non-empty array', 400);
  }

  const results = [];
  let dispatched = 0;
  let failed = 0;

  for (const item of recipients) {
    const recipientId = typeof item === 'string' ? item : item.recipientId || item.id;
    const itemVariables = typeof item === 'object' && item.variables ? item.variables : {};
    const mergedVariables = { ...commonVariables, ...itemVariables };

    try {
      const record = dispatchNotification({
        recipientId,
        templateKey,
        variables: mergedVariables,
        channel: item.channel || channel,
        triggeredBy,
      });
      results.push(record);
      dispatched++;
    } catch (err) {
      failed++;
      results.push({
        recipientId,
        status: 'FAILED',
        error: err.message,
      });
    }
  }

  return {
    total: recipients.length,
    dispatched,
    failed,
    records: results,
  };
};

/**
 * Aggregates delivery metrics across the dispatch history.
 */
const getDispatchStats = () => {
  const byChannel = {};
  const byPriority = {};
  const byTemplate = {};

  for (const r of dispatchHistory) {
    byChannel[r.channel] = (byChannel[r.channel] || 0) + 1;
    byPriority[r.priority] = (byPriority[r.priority] || 0) + 1;
    byTemplate[r.templateKey] = (byTemplate[r.templateKey] || 0) + 1;
  }

  return {
    totalDispatched: dispatchHistory.length,
    byChannel,
    byPriority,
    byTemplate,
  };
};

/**
 * Clears in-memory dispatch history (for testing).
 */
const clearDispatchQueue = () => {
  dispatchHistory = [];
};

module.exports = {
  TEMPLATE_CATALOG,
  getTemplate,
  listTemplates,
  renderTemplate,
  dispatchNotification,
  batchDispatch,
  getDispatchStats,
  clearDispatchQueue,
};
