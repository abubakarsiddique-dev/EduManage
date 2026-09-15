const express = require('express');
const studentsController = require('./students.controller');
const bulkController = require('./bulk.controller');
const { authenticate, authorizeRoles } = require('../../middleware/auth.middleware');
const validate = require('../../middleware/validate.middleware');

const router = express.Router();

router.use(authenticate);

router.get('/', studentsController.getAll);
router.get('/parent/:parentId?', studentsController.getParentChildren);

// Bulk admission and validation endpoints
router.post('/bulk-validate', authorizeRoles('admin'), bulkController.validateBatch);
router.post('/bulk-enroll', authorizeRoles('admin'), bulkController.bulkEnroll);

router.get('/:id', studentsController.getById);

router.post(
  '/',
  authorizeRoles('admin'),
  validate({ required: ['name', 'email'] }),
  studentsController.create
);

router.put('/:id', authorizeRoles('admin', 'teacher'), studentsController.update);
router.delete('/:id', authorizeRoles('admin'), studentsController.remove);

module.exports = router;
