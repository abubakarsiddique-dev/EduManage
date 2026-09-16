const examService = require('./exam.service');
const { asyncHandler } = require('../../middleware/error.middleware');

const getAll = asyncHandler(async (req, res) => {
  const list = await examService.getAll(req.query);
  res.status(200).json({ success: true, count: list.length, data: list });
});

const getById = asyncHandler(async (req, res) => {
  const item = await examService.getById(req.params.id);
  res.status(200).json({ success: true, data: item });
});

const create = asyncHandler(async (req, res) => {
  const item = await examService.create(req.body);
  res.status(201).json({ success: true, message: 'Exam created successfully', data: item });
});

const submitGrades = asyncHandler(async (req, res) => {
  const item = await examService.submitGrades(req.params.id, req.body.grades);
  res.status(200).json({ success: true, message: 'Grades recorded successfully', data: item });
});

const curveExam = asyncHandler(async (req, res) => {
  const result = await examService.curveExam(req.params.id, req.body);
  res.status(200).json({ success: true, message: 'Curve simulation generated', data: result });
});

const getStatistics = asyncHandler(async (req, res) => {
  const stats = await examService.getStatistics(req.params.id);
  res.status(200).json({ success: true, data: stats });
});

const remove = asyncHandler(async (req, res) => {
  await examService.delete(req.params.id);
  res.status(200).json({ success: true, message: 'Exam deleted successfully' });
});

module.exports = {
  getAll,
  getById,
  create,
  submitGrades,
  curveExam,
  getStatistics,
  remove,
};
