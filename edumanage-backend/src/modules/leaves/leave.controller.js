const leaveService = require('./leave.service');
const { asyncHandler } = require('../../middleware/error.middleware');

const getAll = asyncHandler(async (req, res) => {
  const list = await leaveService.getAll(req.query, req.user);
  res.status(200).json({ success: true, count: list.length, data: list });
});

const getById = asyncHandler(async (req, res) => {
  const item = await leaveService.getById(req.params.id);
  res.status(200).json({ success: true, data: item });
});

const applyLeave = asyncHandler(async (req, res) => {
  const item = await leaveService.applyLeave(req.user, req.body);
  res.status(201).json({ success: true, message: 'Leave application submitted', data: item });
});

const updateStatus = asyncHandler(async (req, res) => {
  const item = await leaveService.updateStatus(req.params.id, req.user, req.body);
  res.status(200).json({ success: true, message: `Leave status updated to ${req.body.status}`, data: item });
});

const getStudentImpact = asyncHandler(async (req, res) => {
  const impact = await leaveService.getStudentImpact(req.params.studentId, req.query.proposedDays || 0);
  res.status(200).json({ success: true, data: impact });
});

const remove = asyncHandler(async (req, res) => {
  await leaveService.delete(req.params.id);
  res.status(200).json({ success: true, message: 'Leave request deleted' });
});

module.exports = {
  getAll,
  getById,
  applyLeave,
  updateStatus,
  getStudentImpact,
  remove,
};
