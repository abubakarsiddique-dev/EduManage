const express = require('express');
const router = express.Router();
const { authenticate, authorizeRoles } = require('../../middleware/auth.middleware');
const reportsService = require('./reports.service');

// Admin and teachers: Academic performance summary
router.get(
  '/academic',
  authenticate,
  authorizeRoles('admin', 'teacher'),
  async (req, res, next) => {
    try {
      const data = await reportsService.getAcademicSummaryReport(req.query);
      res.json({
        success: true,
        reportType: 'ACADEMIC_PERFORMANCE_SUMMARY',
        timestamp: new Date().toISOString(),
        data,
      });
    } catch (err) {
      next(err);
    }
  }
);

// Admin and teachers: Attendance overview and absenteeism tracking
router.get(
  '/attendance',
  authenticate,
  authorizeRoles('admin', 'teacher'),
  async (req, res, next) => {
    try {
      const data = await reportsService.getAttendanceOverviewReport(req.query);
      res.json({
        success: true,
        reportType: 'ATTENDANCE_OVERVIEW_SUMMARY',
        timestamp: new Date().toISOString(),
        data,
      });
    } catch (err) {
      next(err);
    }
  }
);

// Admin only: Institutional financial reconciliation
router.get(
  '/financial',
  authenticate,
  authorizeRoles('admin'),
  async (req, res, next) => {
    try {
      const data = await reportsService.getFinancialReconciliationReport(req.query);
      res.json({
        success: true,
        reportType: 'FINANCIAL_RECONCILIATION_REPORT',
        timestamp: new Date().toISOString(),
        data,
      });
    } catch (err) {
      next(err);
    }
  }
);

module.exports = router;
