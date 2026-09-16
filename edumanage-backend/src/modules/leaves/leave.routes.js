const express = require('express');
const router = express.Router();
const controller = require('./leave.controller');
const { authenticate, authorizeRoles } = require('../../middleware/auth.middleware');

router.use(authenticate);

// Student & all authenticated users can view and apply
router.get('/', controller.getAll);
router.post('/', controller.applyLeave);
router.get('/impact/:studentId', controller.getStudentImpact);
router.get('/:id', controller.getById);

// Staff approval & management
router.patch('/:id/status', authorizeRoles('admin', 'teacher'), controller.updateStatus);
router.delete('/:id', authorizeRoles('admin'), controller.remove);

module.exports = router;
