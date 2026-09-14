const db = require('../../db/store');

class ReportsService {
  /**
   * Aggregates academic scores, GPA distributions, pass rates, and subject rankings.
   */
  async getAcademicSummaryReport(query = {}) {
    let results = db.collection('results').find();

    if (query.className || query.class) {
      const cls = (query.className || query.class).toLowerCase();
      results = results.filter(
        (r) => (r.className || r.class || '').toLowerCase() === cls
      );
    }

    if (query.examName) {
      results = results.filter(
        (r) => (r.examName || '').toLowerCase() === query.examName.toLowerCase()
      );
    }

    const totalEvaluated = results.length;
    if (totalEvaluated === 0) {
      return {
        totalEvaluated: 0,
        averageScore: 0,
        highestScore: 0,
        lowestScore: 0,
        passCount: 0,
        failCount: 0,
        passRatePercentage: 0,
        gradeDistribution: { 'A+': 0, 'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0 },
        subjectAverages: [],
        topPerformers: [],
      };
    }

    let totalScore = 0;
    let highestScore = -Infinity;
    let lowestScore = Infinity;
    let passCount = 0;
    let failCount = 0;

    const gradeDistribution = { 'A+': 0, 'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0 };
    const subjectMap = {};

    for (const r of results) {
      const pct = parseFloat(r.percentage || 0);
      totalScore += pct;

      if (pct > highestScore) highestScore = pct;
      if (pct < lowestScore) lowestScore = pct;

      if (pct >= 50.0) {
        passCount++;
      } else {
        failCount++;
      }

      const grade = r.grade || 'F';
      if (gradeDistribution[grade] !== undefined) {
        gradeDistribution[grade]++;
      } else {
        gradeDistribution[grade] = 1;
      }

      const subject = r.subject || 'General';
      if (!subjectMap[subject]) {
        subjectMap[subject] = { total: 0, count: 0 };
      }
      subjectMap[subject].total += pct;
      subjectMap[subject].count++;
    }

    const averageScore = Math.round((totalScore / totalEvaluated) * 100) / 100;
    const passRatePercentage = Math.round((passCount / totalEvaluated) * 10000) / 100;

    const subjectAverages = Object.keys(subjectMap).map((subject) => ({
      subject,
      averageScore: Math.round((subjectMap[subject].total / subjectMap[subject].count) * 100) / 100,
      count: subjectMap[subject].count,
    })).sort((a, b) => b.averageScore - a.averageScore);

    const topPerformers = [...results]
      .sort((a, b) => (parseFloat(b.percentage) || 0) - (parseFloat(a.percentage) || 0))
      .slice(0, 5)
      .map((r) => ({
        studentId: r.studentId,
        studentName: r.studentName,
        className: r.className || r.class,
        subject: r.subject,
        percentage: parseFloat(r.percentage || 0),
        grade: r.grade,
      }));

    return {
      totalEvaluated,
      averageScore,
      highestScore: highestScore === -Infinity ? 0 : highestScore,
      lowestScore: lowestScore === Infinity ? 0 : lowestScore,
      passCount,
      failCount,
      passRatePercentage,
      gradeDistribution,
      subjectAverages,
      topPerformers,
    };
  }

  /**
   * Aggregates institutional attendance records, presence rates, and chronic absenteeism.
   */
  async getAttendanceOverviewReport(query = {}) {
    let records = db.collection('attendance').find();

    if (query.className || query.class) {
      const cls = (query.className || query.class).toLowerCase();
      records = records.filter(
        (r) => (r.className || r.class || '').toLowerCase() === cls
      );
    }

    const totalRecords = records.length;
    let presentCount = 0;
    let absentCount = 0;
    let leaveCount = 0;

    const classStats = {};
    const studentHistory = {};

    for (const r of records) {
      const status = (r.status || 'present').toLowerCase();
      if (status === 'present') presentCount++;
      else if (status === 'absent') absentCount++;
      else if (status === 'leave') leaveCount++;

      const cls = r.className || r.class || 'Unassigned';
      if (!classStats[cls]) {
        classStats[cls] = { present: 0, total: 0 };
      }
      classStats[cls].total++;
      if (status === 'present') classStats[cls].present++;

      const stuId = r.studentId || 'unknown';
      if (!studentHistory[stuId]) {
        studentHistory[stuId] = {
          studentId: stuId,
          studentName: r.studentName || 'Student',
          className: cls,
          present: 0,
          total: 0,
          absent: 0,
        };
      }
      studentHistory[stuId].total++;
      if (status === 'present') studentHistory[stuId].present++;
      if (status === 'absent') studentHistory[stuId].absent++;
    }

    const overallAttendanceRate = totalRecords > 0
      ? Math.round((presentCount / totalRecords) * 10000) / 100
      : 0;

    const byClass = Object.keys(classStats).map((cls) => ({
      className: cls,
      total: classStats[cls].total,
      present: classStats[cls].present,
      ratePercentage: Math.round((classStats[cls].present / classStats[cls].total) * 10000) / 100,
    })).sort((a, b) => b.ratePercentage - a.ratePercentage);

    // Flag chronic absenteeism (attendance rate < 75%)
    const chronicAbsenteeism = Object.values(studentHistory)
      .filter((s) => s.total >= 3 && (s.present / s.total) < 0.75)
      .map((s) => ({
        studentId: s.studentId,
        studentName: s.studentName,
        className: s.className,
        totalRecorded: s.total,
        absentDays: s.absent,
        attendanceRate: Math.round((s.present / s.total) * 10000) / 100,
      }));

    return {
      totalRecords,
      presentCount,
      absentCount,
      leaveCount,
      overallAttendanceRate,
      byClass,
      chronicAbsenteeism,
    };
  }

  /**
   * Aggregates fee collections, invoice reconciliation, and overdue aging.
   */
  async getFinancialReconciliationReport(query = {}) {
    let fees = db.collection('fees').find();

    if (query.year) {
      fees = fees.filter((f) => (f.year || '').toString() === query.year.toString());
    }

    let totalInvoiced = 0;
    let totalCollected = 0;
    let totalPending = 0;
    let totalOverdue = 0;

    const byStatus = {
      paid: { count: 0, amount: 0 },
      pending: { count: 0, amount: 0 },
      overdue: { count: 0, amount: 0 },
      pending_verification: { count: 0, amount: 0 },
    };

    const byFeeType = {};

    for (const f of fees) {
      const amount = parseFloat(f.amount || 0);
      totalInvoiced += amount;

      const status = (f.status || 'pending').toLowerCase();
      if (byStatus[status]) {
        byStatus[status].count++;
        byStatus[status].amount += amount;
      }

      if (status === 'paid') totalCollected += amount;
      else if (status === 'overdue') totalOverdue += amount;
      else totalPending += amount;

      const feeType = f.feeType || 'General Tuition';
      if (!byFeeType[feeType]) {
        byFeeType[feeType] = { count: 0, amount: 0 };
      }
      byFeeType[feeType].count++;
      byFeeType[feeType].amount += amount;
    }

    const collectionEfficiencyPercentage = totalInvoiced > 0
      ? Math.round((totalCollected / totalInvoiced) * 10000) / 100
      : 0;

    return {
      totalInvoiced: Math.round(totalInvoiced * 100) / 100,
      totalCollected: Math.round(totalCollected * 100) / 100,
      totalPending: Math.round(totalPending * 100) / 100,
      totalOverdue: Math.round(totalOverdue * 100) / 100,
      collectionEfficiencyPercentage,
      byStatus,
      byFeeType: Object.keys(byFeeType).map((k) => ({
        feeType: k,
        count: byFeeType[k].count,
        amount: Math.round(byFeeType[k].amount * 100) / 100,
      })),
    };
  }
}

module.exports = new ReportsService();
