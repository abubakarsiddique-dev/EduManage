const bulkService = require('./bulk.service');
const { asyncHandler } = require('../../middleware/error.middleware');

const validateBatch = asyncHandler(async (req, res) => {
  const list = Array.isArray(req.body) ? req.body : req.body.students;
  const report = bulkService.validateBatch(list);
  res.status(200).json({
    success: true,
    data: report,
  });
});

const bulkEnroll = asyncHandler(async (req, res) => {
  const list = Array.isArray(req.body) ? req.body : req.body.students;
  const atomic = req.body.atomic !== undefined ? req.body.atomic === true || req.body.atomic === 'true' : true;
  const result = await bulkService.bulkEnroll(list, { atomic });
  res.status(201).json({
    success: true,
    message: `Successfully processed ${result.enrolledCount} student enrollment(s)`,
    data: result,
  });
});

module.exports = {
  validateBatch,
  bulkEnroll,
};
