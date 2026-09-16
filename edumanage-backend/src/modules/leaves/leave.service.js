const db = require('../../db/store');
const { AppError } = require('../../middleware/error.middleware');

const BadRequestError = (msg) => new AppError(msg, 400);
const NotFoundError = (msg) => new AppError(msg, 404);

class LeaveService {
  get collection() {
    return db.collection('leaves');
  }

  async getAll(query = {}, user = null) {
    return this.collection.find((item) => {
      // If student, restrict to their own records unless admin/teacher
      if (user && user.role === 'student' && item.studentId !== user.id && item.studentId !== user.uid) {
        return false;
      }
      if (query.studentId && item.studentId !== query.studentId) return false;
      if (query.status && item.status !== query.status) return false;
      if (query.leaveType && item.leaveType !== query.leaveType) return false;
      if (query.class && item.class !== query.class) return false;
      return true;
    });
  }

  async getById(id) {
    const leave = this.collection.findById(id);
    if (!leave) throw NotFoundError('Leave request not found');
    return leave;
  }

  async applyLeave(user, data) {
    if (!data.startDate || !data.endDate || !data.reason) {
      throw BadRequestError('startDate, endDate, and reason are required');
    }

    const start = new Date(data.startDate);
    const end = new Date(data.endDate);
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      throw BadRequestError('startDate and endDate must be valid dates (YYYY-MM-DD)');
    }
    if (start > end) {
      throw BadRequestError('startDate cannot be after endDate');
    }

    const diffTime = Math.abs(end.getTime() - start.getTime());
    const daysCount = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;

    // Resolve student metadata
    const studentId = data.studentId || user.id || user.uid;
    const studentDoc = db.collection('students').findById(studentId);

    const leave = {
      studentId,
      studentName: (studentDoc && studentDoc.name) || user.name || 'Student',
      class: (studentDoc && studentDoc.class) || data.class || 'General',
      startDate: data.startDate,
      endDate: data.endDate,
      daysCount,
      leaveType: data.leaveType || 'casual', // 'medical', 'casual', 'emergency', 'academic'
      reason: data.reason.trim(),
      status: 'pending', // 'pending', 'approved', 'rejected', 'cancelled'
      appliedBy: user.email,
      appliedAt: new Date().toISOString(),
      reviewedBy: null,
      reviewedAt: null,
      reviewRemarks: null,
    };

    return this.collection.insert(leave);
  }

  async updateStatus(id, reviewerUser, { status, reviewRemarks }) {
    const leave = await this.getById(id);
    const validStatuses = ['approved', 'rejected', 'cancelled'];
    if (!validStatuses.includes(status)) {
      throw BadRequestError(`Status must be one of: ${validStatuses.join(', ')}`);
    }

    const updated = this.collection.update(id, {
      status,
      reviewRemarks: reviewRemarks || '',
      reviewedBy: reviewerUser.name || reviewerUser.email,
      reviewedAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });
    return updated;
  }

  async getStudentImpact(studentId, proposedDays = 0) {
    // Collect attendance records for this student
    const attendanceRecords = db.collection('attendance').find((item) => {
      if (item.studentId === studentId) return true;
      if (Array.isArray(item.records)) {
        return item.records.some((r) => r.studentId === studentId);
      }
      return false;
    });

    let totalConducted = 0;
    let attended = 0;

    for (const entry of attendanceRecords) {
      if (entry.studentId === studentId) {
        totalConducted++;
        if (entry.status === 'present' || entry.status === 'late') attended++;
      } else if (Array.isArray(entry.records)) {
        const rec = entry.records.find((r) => r.studentId === studentId);
        if (rec) {
          totalConducted++;
          if (rec.status === 'present' || rec.status === 'late') attended++;
        }
      }
    }

    // If student has no attendance history, provide baseline estimate
    const effectiveConducted = totalConducted > 0 ? totalConducted : 50;
    const effectiveAttended = totalConducted > 0 ? attended : 42;

    const currentPct = Math.round((effectiveAttended / effectiveConducted) * 1000) / 10;
    const projectedConducted = effectiveConducted + Number(proposedDays);
    const projectedPct = Math.round((effectiveAttended / projectedConducted) * 1000) / 10;
    const breachesThreshold = projectedPct < 75.0;

    return {
      studentId,
      totalConducted: effectiveConducted,
      attendedCount: effectiveAttended,
      currentPercentage: currentPct,
      proposedLeaveDays: Number(proposedDays),
      projectedPercentage: projectedPct,
      percentageDrop: Math.round((currentPct - projectedPct) * 10) / 10,
      breachesThreshold,
      status: breachesThreshold ? 'at-risk' : 'compliant',
    };
  }

  async delete(id) {
    await this.getById(id);
    return this.collection.delete(id);
  }
}

module.exports = new LeaveService();
