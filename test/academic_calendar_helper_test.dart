import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/academic_calendar_helper.dart';

void main() {
  group('AcademicCalendarHelper Tests', () {
    test('daysRemaining calculates day delta accurately', () {
      final now = DateTime(2026, 5, 2);
      final examDate = DateTime(2026, 5, 12);
      expect(AcademicCalendarHelper.daysRemaining(examDate, now), 10);
    });

    test('isDateInTerm validates interval inclusion', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 6, 30);
      expect(AcademicCalendarHelper.isDateInTerm(DateTime(2026, 5, 2), start, end), isTrue);
      expect(AcademicCalendarHelper.isDateInTerm(DateTime(2026, 7, 15), start, end), isFalse);
    });

    test('calculateTermProgress computes accurate percentage', () {
      final start = DateTime(2026, 1, 1);
      final end = DateTime(2026, 1, 11);
      final mid = DateTime(2026, 1, 6);
      expect(AcademicCalendarHelper.calculateTermProgress(start, end, mid), 50.0);
    });
  });
}
