const db = require('../../db/store');
const { AppError } = require('../../middleware/error.middleware');

function parseMinutes(timeStr) {
  if (!timeStr || typeof timeStr !== 'string') return null;
  const parts = timeStr.trim().split(':');
  if (parts.length !== 2) return null;
  const h = parseInt(parts[0], 10);
  const m = parseInt(parts[1], 10);
  if (isNaN(h) || isNaN(m)) return null;
  return h * 60 + m;
}

function doIntervalsOverlap(startA, endA, startB, endB) {
  return startA < endB && startB < endA;
}

class TimetableService {
  async getAll(query = {}) {
    let list = db.collection('timetable').find();

    if (query.class) {
      list = list.filter((t) => (t.className || t.class || '').toLowerCase() === query.class.toLowerCase());
    }

    if (query.day) {
      list = list.filter((t) => (t.day || '').toLowerCase() === query.day.toLowerCase());
    }

    if (query.teacherId) {
      list = list.filter((t) => t.teacherId === query.teacherId);
    }

    return list.sort((a, b) => (a.startTime || '').localeCompare(b.startTime || ''));
  }

  async getById(id) {
    const item = db.collection('timetable').findById(id);
    if (!item) throw new AppError('Timetable slot not found', 404);
    return item;
  }

  detectConflicts(slotData, excludeId = null) {
    const startMin = parseMinutes(slotData.startTime);
    const endMin = parseMinutes(slotData.endTime);

    if (startMin === null || endMin === null || startMin >= endMin) {
      return [{
        type: 'invalid_interval',
        message: `Invalid slot duration: ${slotData.startTime} - ${slotData.endTime}`,
      }];
    }

    const day = (slotData.day || '').trim().toLowerCase();
    const className = (slotData.className || slotData.class || '').trim().toLowerCase();
    const teacherId = (slotData.teacherId || '').trim();
    const teacherName = (slotData.teacherName || slotData.teacher || '').trim().toLowerCase();
    const room = (slotData.room || '').trim().toLowerCase();

    const existingSlots = db.collection('timetable').find();
    const conflicts = [];

    for (const existing of existingSlots) {
      if (excludeId && existing.id === excludeId) continue;
      if ((existing.day || '').trim().toLowerCase() !== day) continue;

      const exStart = parseMinutes(existing.startTime);
      const exEnd = parseMinutes(existing.endTime);
      if (exStart === null || exEnd === null) continue;

      if (!doIntervalsOverlap(startMin, endMin, exStart, exEnd)) continue;

      // 1. Teacher double-booking
      const exTeacherId = (existing.teacherId || '').trim();
      const exTeacherName = (existing.teacherName || existing.teacher || '').trim().toLowerCase();
      const sameTeacher = (teacherId && exTeacherId && teacherId === exTeacherId) ||
                          (teacherName && exTeacherName && teacherName === exTeacherName);

      if (sameTeacher) {
        conflicts.add ? null : conflicts.push({
          type: 'teacher_conflict',
          message: `Teacher is already scheduled for ${existing.className || existing.class} (${existing.subject}) at ${existing.startTime}-${existing.endTime}`,
          conflictingSlot: existing,
        });
      }

      // 2. Room double-booking
      const exRoom = (existing.room || '').trim().toLowerCase();
      if (room && exRoom && room === exRoom) {
        conflicts.push({
          type: 'room_conflict',
          message: `Room "${existing.room}" is already occupied by ${existing.className || existing.class} (${existing.subject}) at ${existing.startTime}-${existing.endTime}`,
          conflictingSlot: existing,
        });
      }

      // 3. Class schedule collision
      const exClass = (existing.className || existing.class || '').trim().toLowerCase();
      if (className && exClass && className === exClass) {
        conflicts.push({
          type: 'class_conflict',
          message: `Class "${existing.className || existing.class}" already has "${existing.subject}" scheduled at ${existing.startTime}-${existing.endTime}`,
          conflictingSlot: existing,
        });
      }
    }

    return conflicts;
  }

  async create(data) {
    if (!data.allowConflict) {
      const conflicts = this.detectConflicts(data);
      if (conflicts.length > 0) {
        throw new AppError(`Timetable collision: ${conflicts.map((c) => c.message).join('; ')}`, 409);
      }
    }

    return db.collection('timetable').insert({
      className: data.className || data.class,
      class: data.class || data.className,
      day: data.day,
      subject: data.subject,
      startTime: data.startTime,
      endTime: data.endTime,
      teacherId: data.teacherId || '',
      teacherName: data.teacherName || data.teacher || '',
      teacher: data.teacher || data.teacherName || '',
      room: data.room || '',
    });
  }

  async update(id, updates) {
    const existing = db.collection('timetable').findById(id);
    if (!existing) throw new AppError('Timetable slot not found', 404);

    if (!updates.allowConflict) {
      const merged = { ...existing, ...updates };
      const conflicts = this.detectConflicts(merged, id);
      if (conflicts.length > 0) {
        throw new AppError(`Timetable collision: ${conflicts.map((c) => c.message).join('; ')}`, 409);
      }
    }

    const updated = db.collection('timetable').update(id, updates);
    return updated;
  }

  async delete(id) {
    const deleted = db.collection('timetable').delete(id);
    if (!deleted) throw new AppError('Timetable slot not found', 404);
    return true;
  }

  async getAllConflicts(day = null) {
    const list = db.collection('timetable').find();
    const filtered = day
      ? list.filter((t) => (t.day || '').toLowerCase() === day.toLowerCase())
      : list;

    const conflicts = [];
    const n = filtered.length;

    for (let i = 0; i < n; i++) {
      const a = filtered[i];
      const startA = parseMinutes(a.startTime);
      const endA = parseMinutes(a.endTime);
      if (startA === null || endA === null || startA >= endA) continue;

      for (let j = i + 1; j < n; j++) {
        const b = filtered[j];
        if ((a.day || '').toLowerCase() !== (b.day || '').toLowerCase()) continue;

        const startB = parseMinutes(b.startTime);
        const endB = parseMinutes(b.endTime);
        if (startB === null || endB === null || startB >= endB) continue;

        if (!doIntervalsOverlap(startA, endA, startB, endB)) continue;

        // Teacher overlap
        const tA = (a.teacherId || a.teacherName || a.teacher || '').trim().toLowerCase();
        const tB = (b.teacherId || b.teacherName || b.teacher || '').trim().toLowerCase();
        if (tA && tB && tA === tB) {
          conflicts.push({
            type: 'teacher_overlap',
            day: a.day,
            teacher: a.teacherName || a.teacher,
            slotA: a,
            slotB: b,
          });
        }

        // Room overlap
        const rA = (a.room || '').trim().toLowerCase();
        const rB = (b.room || '').trim().toLowerCase();
        if (rA && rB && rA === rB) {
          conflicts.push({
            type: 'room_overlap',
            day: a.day,
            room: a.room,
            slotA: a,
            slotB: b,
          });
        }
      }
    }

    return conflicts;
  }

  async getTeacherWorkload(teacherQuery) {
    const query = (teacherQuery || '').trim().toLowerCase();
    const allSlots = db.collection('timetable').find();

    const slots = allSlots.filter((t) => {
      const tId = (t.teacherId || '').toLowerCase();
      const tName = (t.teacherName || t.teacher || '').toLowerCase();
      return tId === query || tName === query;
    });

    const dailyBreakdown = {};
    let totalMinutes = 0;
    const subjects = new Set();
    const classes = new Set();

    for (const slot of slots) {
      const day = slot.day || 'Unassigned';
      dailyBreakdown[day] = (dailyBreakdown[day] || 0) + 1;

      if (slot.subject) subjects.add(slot.subject);
      if (slot.className || slot.class) classes.add(slot.className || slot.class);

      const s = parseMinutes(slot.startTime);
      const e = parseMinutes(slot.endTime);
      if (s !== null && e !== null && e > s) {
        totalMinutes += (e - s);
      }
    }

    return {
      teacher: teacherQuery,
      totalWeeklyPeriods: slots.length,
      totalHours: parseFloat((totalMinutes / 60).toFixed(2)),
      dailyBreakdown,
      subjects: Array.from(subjects),
      classesTaught: Array.from(classes),
    };
  }
}

module.exports = new TimetableService();
