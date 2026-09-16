const express = require('express');
const router = express.Router();
const controller = require('./exam.controller');
const { authenticate, authorizeRoles } = require('../../middleware/auth.middleware');

// Public to authenticated users
router.use(authenticate);

router.get('/', controller.getAll);
router.get('/:id', controller.getById);
router.get('/:id/statistics', controller.getStatistics);

// Protected to faculty & administrators
router.post('/', authorizeRoles('admin', 'teacher'), controller.create);
router.post('/:id/grades', authorizeRoles('admin', 'teacher'), controller.submitGrades);
router.post('/:id/curve', authorizeRoles('admin', 'teacher'), controller.curveExam);

// Admin only
router.delete('/:id', authorizeRoles('admin'), controller.remove);

module.exports = router;
