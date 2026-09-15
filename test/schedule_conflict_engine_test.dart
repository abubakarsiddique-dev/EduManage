import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/utils/schedule_conflict_engine.dart';
import 'package:school_management_system/data/models/timetable_model.dart';

void main() {
  group('ScheduleConflictEngine Time Helpers', () {
    test('parseTimeToMinutes parses valid HH:mm formats', () {
      expect(ScheduleConflictEngine.parseTimeToMinutes('08:30'), 510);
      expect(ScheduleConflictEngine.parseTimeToMinutes('8:00'), 480);
      expect(ScheduleConflictEngine.parseTimeToMinutes('00:00'), 0);
      expect(ScheduleConflictEngine.parseTimeToMinutes('23:59'), 1439);
      expect(ScheduleConflictEngine.parseTimeToMinutes('14:45'), 885);
    });

    test('parseTimeToMinutes returns null for malformed strings', () {
      expect(ScheduleConflictEngine.parseTimeToMinutes(''), isNull);
      expect(ScheduleConflictEngine.parseTimeToMinutes('invalid'), isNull);
      expect(ScheduleConflictEngine.parseTimeToMinutes('25:00'), isNull);
      expect(ScheduleConflictEngine.parseTimeToMinutes('10:65'), isNull);
      expect(ScheduleConflictEngine.parseTimeToMinutes('12'), isNull);
    });

    test('minutesToTimeString formats integer minutes into HH:mm', () {
      expect(ScheduleConflictEngine.minutesToTimeString(0), '00:00');
      expect(ScheduleConflictEngine.minutesToTimeString(510), '08:30');
      expect(ScheduleConflictEngine.minutesToTimeString(885), '14:45');
      expect(ScheduleConflictEngine.minutesToTimeString(1439), '23:59');
    });

    test('doIntervalsOverlap detects overlapping intervals correctly', () {
      // 09:00 - 10:00 vs 09:30 - 10:30 (Overlap)
      expect(ScheduleConflictEngine.doIntervalsOverlap(540, 600, 570, 630), isTrue);

      // 09:00 - 10:00 vs 10:00 - 11:00 (Adjacent - NO overlap)
      expect(ScheduleConflictEngine.doIntervalsOverlap(540, 600, 600, 660), isFalse);

      // 10:00 - 11:00 vs 09:00 - 10:00 (Adjacent reverse - NO overlap)
      expect(ScheduleConflictEngine.doIntervalsOverlap(600, 660, 540, 600), isFalse);

      // 08:00 - 09:00 vs 11:00 - 12:00 (Disjoint - NO overlap)
      expect(ScheduleConflictEngine.doIntervalsOverlap(480, 540, 660, 720), isFalse);

      // Completely contained: 09:00 - 12:00 vs 10:00 - 11:00
      expect(ScheduleConflictEngine.doIntervalsOverlap(540, 720, 600, 660), isTrue);
    });
  });

  group('ScheduleConflictEngine Conflict Detection', () {
    test('detects teacher double-booking on same day and overlapping time', () {
      final slots = [
        const TimetableModel(
          id: 'slot-1',
          className: 'Grade 10-A',
          day: 'Monday',
          subject: 'Mathematics',
          teacher: 'Prof. John Doe',
          teacherId: 't-1',
          startTime: '09:00',
          endTime: '10:00',
          room: 'Room 101',
        ),
        const TimetableModel(
          id: 'slot-2',
          className: 'Grade 9-B',
          day: 'Monday',
          subject: 'Physics',
          teacher: 'Prof. John Doe',
          teacherId: 't-1',
          startTime: '09:30',
          endTime: '10:30',
          room: 'Lab 2',
        ),
      ];

      final conflicts = ScheduleConflictEngine.detectConflicts(slots);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ScheduleConflictType.teacherCollision);
      expect(conflicts.first.severity, ScheduleConflictSeverity.error);
      expect(conflicts.first.day, 'Monday');
      expect(conflicts.first.entityIdentifier, 'Prof. John Doe');
    });

    test('detects room double-booking collision', () {
      final slots = [
        const TimetableModel(
          id: 'slot-1',
          className: 'Grade 10-A',
          day: 'Tuesday',
          subject: 'Chemistry',
          teacher: 'Dr. Sarah Smith',
          teacherId: 't-2',
          startTime: '11:00',
          endTime: '12:00',
          room: 'Science Lab 1',
        ),
        const TimetableModel(
          id: 'slot-2',
          className: 'Grade 11-C',
          day: 'Tuesday',
          subject: 'Biology',
          teacher: 'Mr. David Lee',
          teacherId: 't-3',
          startTime: '11:30',
          endTime: '12:30',
          room: 'Science Lab 1',
        ),
      ];

      final conflicts = ScheduleConflictEngine.detectConflicts(slots);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ScheduleConflictType.roomCollision);
      expect(conflicts.first.entityIdentifier, 'Science Lab 1');
    });

    test('detects class section collision when two subjects are assigned to same class', () {
      final slots = [
        const TimetableModel(
          id: 'slot-1',
          className: 'Grade 8-Green',
          day: 'Wednesday',
          subject: 'English',
          teacher: 'Ms. Emily White',
          startTime: '10:00',
          endTime: '10:45',
          room: 'Room 204',
        ),
        const TimetableModel(
          id: 'slot-2',
          className: 'Grade 8-Green',
          day: 'Wednesday',
          subject: 'History',
          teacher: 'Mr. Robert Green',
          startTime: '10:30',
          endTime: '11:15',
          room: 'Room 205',
        ),
      ];

      final conflicts = ScheduleConflictEngine.detectConflicts(slots);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ScheduleConflictType.classSectionCollision);
      expect(conflicts.first.entityIdentifier, 'Grade 8-Green');
    });

    test('allows contiguous consecutive slots without conflict', () {
      final slots = [
        const TimetableModel(
          id: 'slot-1',
          className: 'Grade 10-A',
          day: 'Thursday',
          subject: 'Math',
          teacher: 'Prof. John Doe',
          teacherId: 't-1',
          startTime: '09:00',
          endTime: '09:45',
          room: 'Room 101',
        ),
        const TimetableModel(
          id: 'slot-2',
          className: 'Grade 10-B',
          day: 'Thursday',
          subject: 'Math',
          teacher: 'Prof. John Doe',
          teacherId: 't-1',
          startTime: '09:45',
          endTime: '10:30',
          room: 'Room 102',
        ),
      ];

      final conflicts = ScheduleConflictEngine.detectConflicts(slots);
      expect(conflicts, isEmpty);
    });

    test('detects invalid time intervals (start >= end)', () {
      final slots = [
        const TimetableModel(
          id: 'slot-err',
          className: 'Grade 10-A',
          day: 'Friday',
          subject: 'Geography',
          teacher: 'Ms. Clara',
          startTime: '11:00',
          endTime: '10:00', // invalid
        ),
      ];

      final conflicts = ScheduleConflictEngine.detectConflicts(slots);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ScheduleConflictType.invalidTimeRange);
      expect(conflicts.first.severity, ScheduleConflictSeverity.error);
    });

    test('flags warning for periods outside operating hours', () {
      final slots = [
        const TimetableModel(
          id: 'slot-early',
          className: 'Grade 12-A',
          day: 'Monday',
          subject: 'Zero Period Physics',
          teacher: 'Prof. Alan',
          startTime: '06:30', // Before 07:30 default opening
          endTime: '07:15',
        ),
      ];

      final conflicts = ScheduleConflictEngine.detectConflicts(slots);
      expect(conflicts.length, 1);
      expect(conflicts.first.type, ScheduleConflictType.outsideOperatingHours);
      expect(conflicts.first.severity, ScheduleConflictSeverity.warning);
    });
  });

  group('ScheduleConflictEngine Workload Analysis', () {
    test('calculates teacher periods, hours, and overload alert', () {
      final slots = [
        const TimetableModel(
          id: '1',
          className: 'Grade 9-A',
          day: 'Monday',
          subject: 'Math',
          teacher: 'John Doe',
          teacherId: 't-1',
          startTime: '08:00',
          endTime: '09:00',
        ),
        const TimetableModel(
          id: '2',
          className: 'Grade 9-B',
          day: 'Monday',
          subject: 'Math',
          teacher: 'John Doe',
          teacherId: 't-1',
          startTime: '09:00',
          endTime: '10:00',
        ),
        const TimetableModel(
          id: '3',
          className: 'Grade 10-A',
          day: 'Monday',
          subject: 'Math',
          teacher: 'John Doe',
          teacherId: 't-1',
          startTime: '10:00',
          endTime: '11:00',
        ),
        const TimetableModel(
          id: '4',
          className: 'Grade 10-B',
          day: 'Monday',
          subject: 'Math',
          teacher: 'John Doe',
          teacherId: 't-1',
          startTime: '11:00',
          endTime: '12:00',
        ),
        const TimetableModel(
          id: '5',
          className: 'Grade 11-A',
          day: 'Tuesday',
          subject: 'Math',
          teacher: 'John Doe',
          teacherId: 't-1',
          startTime: '09:00',
          endTime: '10:30', // 1.5 hours
        ),
      ];

      final workloads = ScheduleConflictEngine.analyzeTeacherWorkloads(slots, maxDailyPeriods: 3);
      expect(workloads.containsKey('t-1'), isTrue);

      final wl = workloads['t-1']!;
      expect(wl.totalWeeklyPeriods, 5);
      expect(wl.totalTeachingHours, 5.5); // 4 * 1.0 + 1.5
      expect(wl.maxPeriodsInOneDay, 4);
      expect(wl.isOverloaded, isTrue); // 4 > maxDailyPeriods of 3
      expect(wl.classesTaught, containsAll(['Grade 9-A', 'Grade 9-B', 'Grade 10-A', 'Grade 10-B', 'Grade 11-A']));
    });
  });

  group('ScheduleConflictEngine Available Slots Finder', () {
    test('finds open gaps between scheduled periods on a day', () {
      final slots = [
        const TimetableModel(
          id: '1',
          className: 'Grade 10-A',
          day: 'Monday',
          subject: 'Math',
          teacher: 'John',
          startTime: '09:00',
          endTime: '10:00',
        ),
        const TimetableModel(
          id: '2',
          className: 'Grade 10-A',
          day: 'Monday',
          subject: 'English',
          teacher: 'Mary',
          startTime: '11:00',
          endTime: '12:00',
        ),
      ];

      // Operating day: 08:00 (480) to 13:00 (780)
      final gaps = ScheduleConflictEngine.findAvailableSlots(
        existingSlots: slots,
        day: 'Monday',
        durationMinutes: 45,
        dayStartMinutes: 8 * 60, // 08:00
        dayEndMinutes: 13 * 60,  // 13:00
        filterClass: 'Grade 10-A',
      );

      // Expected gaps:
      // 1. 08:00 to 09:00 (60 min >= 45)
      // 2. 10:00 to 11:00 (60 min >= 45)
      // 3. 12:00 to 13:00 (60 min >= 45)
      expect(gaps.length, 3);
      expect(gaps[0].startTimeFormatted, '08:00');
      expect(gaps[0].endTimeFormatted, '09:00');
      expect(gaps[1].startTimeFormatted, '10:00');
      expect(gaps[1].endTimeFormatted, '11:00');
      expect(gaps[2].startTimeFormatted, '12:00');
      expect(gaps[2].endTimeFormatted, '13:00');
    });
  });
}
