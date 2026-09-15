const timetableService = require('./timetable.service');
const { asyncHandler } = require('../../middleware/error.middleware');

const getAll = asyncHandler(async (req, res) => {
  const list = await timetableService.getAll(req.query);
  res.status(200).json({ success: true, count: list.length, data: list });
});

const getById = asyncHandler(async (req, res) => {
  const item = await timetableService.getById(req.params.id);
  res.status(200).json({ success: true, data: item });
});

const create = asyncHandler(async (req, res) => {
  const item = await timetableService.create(req.body);
  res.status(201).json({ success: true, message: 'Timetable entry added', data: item });
});

const update = asyncHandler(async (req, res) => {
  const item = await timetableService.update(req.params.id, req.body);
  res.status(200).json({ success: true, message: 'Timetable entry updated', data: item });
});

const remove = asyncHandler(async (req, res) => {
  await timetableService.delete(req.params.id);
  res.status(200).json({ success: true, message: 'Timetable entry removed' });
});

const validateSlot = asyncHandler(async (req, res) => {
  const conflicts = timetableService.detectConflicts(req.body, req.body.id || null);
  res.status(200).json({
    success: true,
    valid: conflicts.length === 0,
    conflictCount: conflicts.length,
    conflicts,
  });
});

const getConflicts = asyncHandler(async (req, res) => {
  const conflicts = await timetableService.getAllConflicts(req.query.day);
  res.status(200).json({
    success: true,
    count: conflicts.length,
    data: conflicts,
  });
});

const getWorkload = asyncHandler(async (req, res) => {
  const workload = await timetableService.getTeacherWorkload(req.params.teacherId);
  res.status(200).json({
    success: true,
    data: workload,
  });
});

module.exports = {
  getAll,
  getById,
  create,
  update,
  remove,
  validateSlot,
  getConflicts,
  getWorkload,
};
