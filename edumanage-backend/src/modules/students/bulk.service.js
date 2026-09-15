const db = require('../../db/store');
const { AppError } = require('../../middleware/error.middleware');

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

class BulkEnrollmentService {
  validateBatch(students = []) {
    if (!Array.isArray(students) || students.length === 0) {
      throw new AppError('A non-empty array of students is required for bulk processing', 400);
    }

    const errors = [];
    const validRows = [];
    const seenEmails = new Set();
    const seenRollNos = new Set();
    const existingStudents = db.collection('students').find();

    for (let i = 0; i < students.length; i++) {
      const row = students[i];
      const rowIndex = i + 1;
      const rowErrors = [];

      if (!row || typeof row !== 'object') {
        errors.push({
          row: rowIndex,
          data: row,
          reasons: ['Row must be a valid student object'],
        });
        continue;
      }

      if (!row.name || typeof row.name !== 'string' || row.name.trim().length === 0) {
        rowErrors.push('Student name is required');
      }

      if (!row.email || typeof row.email !== 'string' || !EMAIL_REGEX.test(row.email.trim())) {
        rowErrors.push('Valid student email address is required');
      } else {
        const cleanEmail = row.email.trim().toLowerCase();
        if (seenEmails.has(cleanEmail)) {
          rowErrors.push(`Duplicate email "${cleanEmail}" within batch`);
        } else {
          seenEmails.add(cleanEmail);
        }

        const existingWithEmail = existingStudents.find(
          (s) => (s.email || '').trim().toLowerCase() === cleanEmail
        );
        if (existingWithEmail) {
          rowErrors.push(`Student with email "${cleanEmail}" already exists in the system`);
        }
      }

      if (!row.class && !row.className) {
        rowErrors.push('Class designation is required');
      }

      const roll = (row.rollNo || row.rollNumber || '').trim();
      const targetClass = (row.class || row.className || '').trim();

      if (roll && targetClass) {
        const rollKey = `${targetClass.toLowerCase()}_${roll.toLowerCase()}`;
        if (seenRollNos.has(rollKey)) {
          rowErrors.push(`Duplicate roll number "${roll}" in class "${targetClass}" within batch`);
        } else {
          seenRollNos.add(rollKey);
        }

        const existingWithRoll = existingStudents.find(
          (s) =>
            (s.class || s.className || '').trim().toLowerCase() === targetClass.toLowerCase() &&
            (s.rollNo || '').trim().toLowerCase() === roll.toLowerCase()
        );
        if (existingWithRoll) {
          rowErrors.push(`Roll number "${roll}" is already assigned in class "${targetClass}"`);
        }
      }

      if (rowErrors.length > 0) {
        errors.push({
          row: rowIndex,
          data: row,
          reasons: rowErrors,
        });
      } else {
        validRows.push({
          name: row.name.trim(),
          email: row.email.trim().toLowerCase(),
          class: targetClass,
          section: (row.section || '').trim(),
          rollNo: roll,
          contact: (row.contact || row.phone || '').trim(),
          approved: row.approved !== undefined ? !!row.approved : true,
        });
      }
    }

    return {
      totalRows: students.length,
      validCount: validRows.length,
      errorCount: errors.length,
      isValid: errors.length === 0,
      validRows,
      errors,
    };
  }

  async bulkEnroll(students = [], options = { atomic: true }) {
    const report = this.validateBatch(students);

    if (options.atomic && !report.isValid) {
      throw new AppError(
        `Bulk enrollment aborted due to ${report.errorCount} validation failure(s)`,
        422,
        report.errors
      );
    }

    const studentsCol = db.collection('students');
    const enrolled = [];

    for (const validData of report.validRows) {
      const created = studentsCol.insert(validData);
      enrolled.push(created);
    }

    return {
      success: true,
      mode: options.atomic ? 'atomic' : 'partial',
      totalSubmitted: students.length,
      enrolledCount: enrolled.length,
      failedCount: report.errorCount,
      enrolled,
      failures: report.errors,
    };
  }
}

module.exports = new BulkEnrollmentService();
