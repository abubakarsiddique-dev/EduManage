import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/utils/date_time_helper.dart';

void main() {
  group('DateTimeHelper Utility Suite', () {
    final testDate = DateTime(2026, 9, 10, 14, 30); // 2026-09-10 2:30 PM

    test('formatIsoDate formats standard date string', () {
      expect(DateTimeHelper.formatIsoDate(testDate), '2026-09-10');
      expect(DateTimeHelper.formatIsoDate(null), '');
    });

    test('formatDisplayDate formats readable date string', () {
      expect(DateTimeHelper.formatDisplayDate(testDate), 'Sep 10, 2026');
      expect(DateTimeHelper.formatDisplayDate(null), '');
    });

    test('formatDisplayTime formats readable 12-hour clock string', () {
      expect(DateTimeHelper.formatDisplayTime(testDate), '2:30 PM');
      expect(DateTimeHelper.formatDisplayTime(null), '');
    });

    test('formatFullDateTime combines date and time cleanly', () {
      expect(DateTimeHelper.formatFullDateTime(testDate), 'Sep 10, 2026 • 2:30 PM');
      expect(DateTimeHelper.formatFullDateTime(null), '');
    });

    test('formatMonthYear formats month and year', () {
      expect(DateTimeHelper.formatMonthYear(testDate), 'September 2026');
      expect(DateTimeHelper.formatMonthYear(null), '');
    });

    test('timeAgo computes relative timestamps accurately', () {
      final base = DateTime(2026, 9, 10, 12, 0, 0);

      // Future
      expect(
        DateTimeHelper.timeAgo(base.add(const Duration(minutes: 5)), clock: base),
        'In the future',
      );

      // Just now (< 45 sec)
      expect(
        DateTimeHelper.timeAgo(base.subtract(const Duration(seconds: 20)), clock: base),
        'Just now',
      );

      // Minutes ago
      expect(
        DateTimeHelper.timeAgo(base.subtract(const Duration(minutes: 15)), clock: base),
        '15m ago',
      );

      // Hours ago
      expect(
        DateTimeHelper.timeAgo(base.subtract(const Duration(hours: 4)), clock: base),
        '4h ago',
      );

      // Yesterday
      expect(
        DateTimeHelper.timeAgo(base.subtract(const Duration(days: 1)), clock: base),
        'Yesterday',
      );

      // Days ago
      expect(
        DateTimeHelper.timeAgo(base.subtract(const Duration(days: 4)), clock: base),
        '4d ago',
      );

      // Weeks ago
      expect(
        DateTimeHelper.timeAgo(base.subtract(const Duration(days: 15)), clock: base),
        '2w ago',
      );

      // Null case
      expect(DateTimeHelper.timeAgo(null), '');
    });

    test('isSameDay and isToday check calendar day identity', () {
      final date1 = DateTime(2026, 9, 10, 8, 0);
      final date2 = DateTime(2026, 9, 10, 23, 59);
      final date3 = DateTime(2026, 9, 11, 8, 0);

      expect(DateTimeHelper.isSameDay(date1, date2), isTrue);
      expect(DateTimeHelper.isSameDay(date1, date3), isFalse);
      expect(DateTimeHelper.isSameDay(null, date1), isFalse);

      expect(DateTimeHelper.isToday(date1, clock: date2), isTrue);
      expect(DateTimeHelper.isToday(date3, clock: date2), isFalse);
    });

    test('safeParse parses valid and handles invalid ISO strings', () {
      expect(DateTimeHelper.safeParse('2026-09-10'), DateTime(2026, 9, 10));
      expect(DateTimeHelper.safeParse('invalid-date'), isNull);
      expect(DateTimeHelper.safeParse(''), isNull);
      expect(DateTimeHelper.safeParse(null), isNull);
    });

    test('daysUntil calculates deadline differences correctly', () {
      final clock = DateTime(2026, 9, 10);
      final future = DateTime(2026, 9, 15);
      final past = DateTime(2026, 9, 5);

      expect(DateTimeHelper.daysUntil(future, clock: clock), 5);
      expect(DateTimeHelper.daysUntil(past, clock: clock), -5);
      expect(DateTimeHelper.daysUntil(clock, clock: clock), 0);
      expect(DateTimeHelper.daysUntil(null), 0);
    });

    test('isDateInRange accurately determines date boundaries', () {
      final start = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 30);
      final within = DateTime(2026, 9, 15);
      final before = DateTime(2026, 8, 31);
      final after = DateTime(2026, 10, 1);

      expect(DateTimeHelper.isDateInRange(within, start, end), isTrue);
      expect(DateTimeHelper.isDateInRange(start, start, end), isTrue);
      expect(DateTimeHelper.isDateInRange(end, start, end), isTrue);
      expect(DateTimeHelper.isDateInRange(before, start, end), isFalse);
      expect(DateTimeHelper.isDateInRange(after, start, end), isFalse);
      expect(DateTimeHelper.isDateInRange(null, start, end), isFalse);
    });

    test('formatAcademicYear formats school sessions correctly', () {
      expect(DateTimeHelper.formatAcademicYear(DateTime(2026, 9, 15)), '2026-2027');
      expect(DateTimeHelper.formatAcademicYear(DateTime(2026, 3, 20)), '2025-2026');
      expect(DateTimeHelper.formatAcademicYear(DateTime(2026, 8, 1)), '2026-2027');
      expect(DateTimeHelper.formatAcademicYear(null), '');
    });

    test('getQuarter computes correct fiscal and academic quarters', () {
      expect(DateTimeHelper.getQuarter(DateTime(2026, 1, 15)), 'Q1');
      expect(DateTimeHelper.getQuarter(DateTime(2026, 5, 20)), 'Q2');
      expect(DateTimeHelper.getQuarter(DateTime(2026, 9, 10)), 'Q3');
      expect(DateTimeHelper.getQuarter(DateTime(2026, 11, 30)), 'Q4');
      expect(DateTimeHelper.getQuarter(null), '');
    });

    test('startOfWeek and endOfWeek calculate calendar week limits', () {
      // 2026-09-23 is Wednesday (weekday 3)
      final wednesday = DateTime(2026, 9, 23);
      final monday = DateTimeHelper.startOfWeek(wednesday);
      final sunday = DateTimeHelper.endOfWeek(wednesday);

      expect(monday, DateTime(2026, 9, 21));
      expect(sunday, DateTime(2026, 9, 27, 23, 59, 59));
      expect(DateTimeHelper.startOfWeek(null), isNull);
      expect(DateTimeHelper.endOfWeek(null), isNull);
    });
  });
}

