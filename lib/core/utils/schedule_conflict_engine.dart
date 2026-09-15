import '../../data/models/timetable_model.dart';

/// Enum representing the category of scheduling collision or validation fault.
enum ScheduleConflictType {
  teacherCollision,
  roomCollision,
  classSectionCollision,
  invalidTimeRange,
  outsideOperatingHours,
}

/// Severity level of the detected scheduling conflict.
enum ScheduleConflictSeverity {
  error,
  warning,
}

/// Represents an identified schedule conflict between one or two timetable slots.
class ScheduleConflict {
  final ScheduleConflictType type;
  final ScheduleConflictSeverity severity;
  final String day;
  final String message;
  final TimetableModel primarySlot;
  final TimetableModel? conflictingSlot;
  final String? entityIdentifier;

  const ScheduleConflict({
    required this.type,
    required this.severity,
    required this.day,
    required this.message,
    required this.primarySlot,
    this.conflictingSlot,
    this.entityIdentifier,
  });

  @override
  String toString() =>
      'ScheduleConflict($type, severity: $severity, day: $day, message: "$message")';
}

/// Summary of an instructor's assigned teaching load and weekly distribution.
class TeacherWorkload {
  final String teacherName;
  final String? teacherId;
  final int totalWeeklyPeriods;
  final double totalTeachingHours;
  final Map<String, int> dailyPeriods;
  final int maxPeriodsInOneDay;
  final bool isOverloaded;
  final List<String> subjects;
  final List<String> classesTaught;

  const TeacherWorkload({
    required this.teacherName,
    this.teacherId,
    required this.totalWeeklyPeriods,
    required this.totalTeachingHours,
    required this.dailyPeriods,
    required this.maxPeriodsInOneDay,
    required this.isOverloaded,
    required this.subjects,
    required this.classesTaught,
  });

  @override
  String toString() =>
      'TeacherWorkload($teacherName: $totalWeeklyPeriods periods, ${totalTeachingHours.toStringAsFixed(1)} hrs, overloaded: $isOverloaded)';
}

/// Represents an available time window open for scheduling.
class AvailableTimeWindow {
  final String day;
  final int startMinutes;
  final int endMinutes;

  const AvailableTimeWindow({
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
  });

  int get durationMinutes => endMinutes - startMinutes;

  String get startTimeFormatted => ScheduleConflictEngine.minutesToTimeString(startMinutes);
  String get endTimeFormatted => ScheduleConflictEngine.minutesToTimeString(endMinutes);

  @override
  String toString() => '$day $startTimeFormatted - $endTimeFormatted ($durationMinutes min)';
}

/// Enterprise engine for validating timetable constraints, identifying collisions,
/// and computing teacher workload distribution.
class ScheduleConflictEngine {
  /// Default institutional opening time: 07:30 (450 minutes from midnight).
  static const int defaultDayStartMinutes = 7 * 60 + 30;

  /// Default institutional closing time: 18:00 (1080 minutes from midnight).
  static const int defaultDayEndMinutes = 18 * 60;

  /// Parses a time string (e.g., "08:30", "8:30", "14:15") into total minutes from midnight.
  /// Returns null if format is invalid.
  static int? parseTimeToMinutes(String timeStr) {
    final clean = timeStr.trim();
    if (clean.isEmpty) return null;

    final parts = clean.split(':');
    if (parts.length != 2) return null;

    final hours = int.tryParse(parts[0].trim());
    final minutes = int.tryParse(parts[1].trim());

    if (hours == null || minutes == null) return null;
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) return null;

    return hours * 60 + minutes;
  }

  /// Converts minutes from midnight into a 24-hour "HH:mm" formatted string.
  static String minutesToTimeString(int minutes) {
    final clamped = minutes.clamp(0, 1439);
    final h = (clamped ~/ 60).toString().padLeft(2, '0');
    final m = (clamped % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Determines whether two half-open intervals [startA, endA) and [startB, endB) overlap.
  /// Note: Adjacent periods (e.g. 09:00-10:00 and 10:00-11:00) do NOT overlap.
  static bool doIntervalsOverlap(int startA, int endA, int startB, int endB) {
    return startA < endB && startB < endA;
  }

  /// Analyzes a collection of timetable slots and returns all identified conflicts.
  static List<ScheduleConflict> detectConflicts(
    List<TimetableModel> slots, {
    int dayStartMinutes = defaultDayStartMinutes,
    int dayEndMinutes = defaultDayEndMinutes,
  }) {
    final conflicts = <ScheduleConflict>[];
    final validSlots = <TimetableModel>[];

    // 1. Single-slot structural validations
    for (final slot in slots) {
      final startMin = parseTimeToMinutes(slot.startTime);
      final endMin = parseTimeToMinutes(slot.endTime);

      if (startMin == null || endMin == null || startMin >= endMin) {
        conflicts.add(ScheduleConflict(
          type: ScheduleConflictType.invalidTimeRange,
          severity: ScheduleConflictSeverity.error,
          day: slot.day,
          message: 'Slot "${slot.subject}" in ${slot.className} has invalid time interval: ${slot.startTime} - ${slot.endTime}',
          primarySlot: slot,
        ));
        continue;
      }

      if (startMin < dayStartMinutes || endMin > dayEndMinutes) {
        conflicts.add(ScheduleConflict(
          type: ScheduleConflictType.outsideOperatingHours,
          severity: ScheduleConflictSeverity.warning,
          day: slot.day,
          message: 'Slot "${slot.subject}" in ${slot.className} (${slot.timeRange}) operates outside institutional hours (${minutesToTimeString(dayStartMinutes)} - ${minutesToTimeString(dayEndMinutes)})',
          primarySlot: slot,
        ));
      }

      validSlots.add(slot);
    }

    // 2. Pairwise collision detections across the same day
    final n = validSlots.length;
    for (int i = 0; i < n; i++) {
      final a = validSlots[i];
      final startA = parseTimeToMinutes(a.startTime)!;
      final endA = parseTimeToMinutes(a.endTime)!;
      final dayA = a.day.trim().toLowerCase();

      for (int j = i + 1; j < n; j++) {
        final b = validSlots[j];
        final dayB = b.day.trim().toLowerCase();

        // Must be on the same day to collide
        if (dayA != dayB) continue;

        final startB = parseTimeToMinutes(b.startTime)!;
        final endB = parseTimeToMinutes(b.endTime)!;

        // Must have overlapping time interval
        if (!doIntervalsOverlap(startA, endA, startB, endB)) continue;

        // A. Teacher collision check
        final teacherMatch = _isSameTeacher(a, b);
        if (teacherMatch) {
          final teacherName = a.teacher.isNotEmpty ? a.teacher : b.teacher;
          conflicts.add(ScheduleConflict(
            type: ScheduleConflictType.teacherCollision,
            severity: ScheduleConflictSeverity.error,
            day: a.day,
            message: 'Teacher "$teacherName" is double-booked on ${a.day} between ${a.className} (${a.subject}) and ${b.className} (${b.subject})',
            primarySlot: a,
            conflictingSlot: b,
            entityIdentifier: teacherName,
          ));
        }

        // B. Room collision check
        final roomA = (a.room ?? '').trim().toLowerCase();
        final roomB = (b.room ?? '').trim().toLowerCase();
        if (roomA.isNotEmpty && roomB.isNotEmpty && roomA == roomB) {
          conflicts.add(ScheduleConflict(
            type: ScheduleConflictType.roomCollision,
            severity: ScheduleConflictSeverity.error,
            day: a.day,
            message: 'Room "${a.room}" is double-booked on ${a.day} for "${a.subject}" (${a.className}) and "${b.subject}" (${b.className})',
            primarySlot: a,
            conflictingSlot: b,
            entityIdentifier: a.room,
          ));
        }

        // C. Class section collision check
        final classA = a.className.trim().toLowerCase();
        final classB = b.className.trim().toLowerCase();
        if (classA.isNotEmpty && classA == classB) {
          conflicts.add(ScheduleConflict(
            type: ScheduleConflictType.classSectionCollision,
            severity: ScheduleConflictSeverity.error,
            day: a.day,
            message: 'Class "$classA" has overlapping sessions: "${a.subject}" and "${b.subject}" on ${a.day}',
            primarySlot: a,
            conflictingSlot: b,
            entityIdentifier: a.className,
          ));
        }
      }
    }

    return conflicts;
  }

  /// Calculates workload statistics for all teachers found in the timetable.
  static Map<String, TeacherWorkload> analyzeTeacherWorkloads(
    List<TimetableModel> slots, {
    int maxDailyPeriods = 5,
  }) {
    final Map<String, List<TimetableModel>> teacherMap = {};

    for (final slot in slots) {
      final key = _getTeacherKey(slot);
      if (key.isEmpty) continue;
      teacherMap.putIfAbsent(key, () => []).add(slot);
    }

    final results = <String, TeacherWorkload>{};

    for (final entry in teacherMap.entries) {
      final teacherSlots = entry.value;
      final teacherName = teacherSlots.first.teacher.isNotEmpty
          ? teacherSlots.first.teacher
          : entry.key;
      final teacherId = teacherSlots.first.teacherId;

      final dailyPeriods = <String, int>{};
      double totalMinutes = 0;
      final subjects = <String>{};
      final classes = <String>{};

      for (final slot in teacherSlots) {
        final day = slot.day.trim();
        dailyPeriods[day] = (dailyPeriods[day] ?? 0) + 1;

        if (slot.subject.isNotEmpty) subjects.add(slot.subject);
        if (slot.className.isNotEmpty) classes.add(slot.className);

        final start = parseTimeToMinutes(slot.startTime);
        final end = parseTimeToMinutes(slot.endTime);
        if (start != null && end != null && end > start) {
          totalMinutes += (end - start);
        }
      }

      int maxDaily = 0;
      for (final count in dailyPeriods.values) {
        if (count > maxDaily) maxDaily = count;
      }

      results[entry.key] = TeacherWorkload(
        teacherName: teacherName,
        teacherId: teacherId,
        totalWeeklyPeriods: teacherSlots.length,
        totalTeachingHours: totalMinutes / 60.0,
        dailyPeriods: dailyPeriods,
        maxPeriodsInOneDay: maxDaily,
        isOverloaded: maxDaily > maxDailyPeriods,
        subjects: subjects.toList()..sort(),
        classesTaught: classes.toList()..sort(),
      );
    }

    return results;
  }

  /// Discovers available non-overlapping time windows on a given day.
  static List<AvailableTimeWindow> findAvailableSlots({
    required List<TimetableModel> existingSlots,
    required String day,
    int durationMinutes = 45,
    int dayStartMinutes = defaultDayStartMinutes,
    int dayEndMinutes = defaultDayEndMinutes,
    String? filterClass,
    String? filterTeacher,
    String? filterRoom,
  }) {
    final targetDay = day.trim().toLowerCase();

    // Filter relevant occupied intervals for the specified criteria
    final occupiedIntervals = <List<int>>[];

    for (final slot in existingSlots) {
      if (slot.day.trim().toLowerCase() != targetDay) continue;

      bool isRelevant = false;
      if (filterClass != null &&
          slot.className.trim().toLowerCase() == filterClass.trim().toLowerCase()) {
        isRelevant = true;
      }
      if (filterTeacher != null &&
          _isTeacherMatch(slot, filterTeacher)) {
        isRelevant = true;
      }
      if (filterRoom != null &&
          (slot.room ?? '').trim().toLowerCase() == filterRoom.trim().toLowerCase()) {
        isRelevant = true;
      }

      // If no specific filters provided, take all slots for the day
      if (filterClass == null && filterTeacher == null && filterRoom == null) {
        isRelevant = true;
      }

      if (isRelevant) {
        final start = parseTimeToMinutes(slot.startTime);
        final end = parseTimeToMinutes(slot.endTime);
        if (start != null && end != null && end > start) {
          occupiedIntervals.add([start, end]);
        }
      }
    }

    // Sort intervals chronologically
    occupiedIntervals.sort((a, b) => a[0].compareTo(b[0]));

    // Merge overlapping/adjacent intervals
    final mergedIntervals = <List<int>>[];
    for (final interval in occupiedIntervals) {
      if (mergedIntervals.isEmpty) {
        mergedIntervals.add(interval);
      } else {
        final last = mergedIntervals.last;
        if (interval[0] <= last[1]) {
          // Overlapping or contiguous
          if (interval[1] > last[1]) {
            last[1] = interval[1];
          }
        } else {
          mergedIntervals.add(interval);
        }
      }
    }

    // Find gaps of at least durationMinutes
    final available = <AvailableTimeWindow>[];
    int current = dayStartMinutes;

    for (final busy in mergedIntervals) {
      final busyStart = busy[0];
      final busyEnd = busy[1];

      if (busyStart > current && (busyStart - current) >= durationMinutes) {
        available.add(AvailableTimeWindow(
          day: day,
          startMinutes: current,
          endMinutes: busyStart,
        ));
      }
      if (busyEnd > current) {
        current = busyEnd;
      }
    }

    if (dayEndMinutes > current && (dayEndMinutes - current) >= durationMinutes) {
      available.add(AvailableTimeWindow(
        day: day,
        startMinutes: current,
        endMinutes: dayEndMinutes,
      ));
    }

    return available;
  }

  // --- Internal Helpers ---

  static String _getTeacherKey(TimetableModel slot) {
    if (slot.teacherId != null && slot.teacherId!.trim().isNotEmpty) {
      return slot.teacherId!.trim();
    }
    return slot.teacher.trim().toLowerCase();
  }

  static bool _isSameTeacher(TimetableModel a, TimetableModel b) {
    if (a.teacherId != null &&
        b.teacherId != null &&
        a.teacherId!.trim().isNotEmpty &&
        b.teacherId!.trim().isNotEmpty) {
      return a.teacherId!.trim() == b.teacherId!.trim();
    }
    final tA = a.teacher.trim().toLowerCase();
    final tB = b.teacher.trim().toLowerCase();
    return tA.isNotEmpty && tB.isNotEmpty && tA == tB;
  }

  static bool _isTeacherMatch(TimetableModel slot, String teacherQuery) {
    final query = teacherQuery.trim().toLowerCase();
    if (slot.teacherId != null && slot.teacherId!.trim().toLowerCase() == query) {
      return true;
    }
    return slot.teacher.trim().toLowerCase() == query;
  }
}
