import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_management_system/core/utils/data_helpers.dart';
import 'package:school_management_system/core/theme/app_colors.dart';

void main() {
  group('DataHelpers Test Suite', () {
    test('letterGrade maps scores to standard letter grades', () {
      expect(DataHelpers.letterGrade(95.0), 'A+');
      expect(DataHelpers.letterGrade(85.0), 'A');
      expect(DataHelpers.letterGrade(75.0), 'B+');
      expect(DataHelpers.letterGrade(65.0), 'B');
      expect(DataHelpers.letterGrade(55.0), 'C');
      expect(DataHelpers.letterGrade(45.0), 'D');
      expect(DataHelpers.letterGrade(35.0), 'F');
    });

    test('gradeColor assigns appropriate semantic colors', () {
      expect(DataHelpers.gradeColor(90.0), AppColors.success);
      expect(DataHelpers.gradeColor(70.0), AppColors.primary);
      expect(DataHelpers.gradeColor(50.0), AppColors.warning);
      expect(DataHelpers.gradeColor(30.0), AppColors.danger);
    });

    test('dateKey formats DateTime with zero-padded year, month, and day', () {
      final date = DateTime(2026, 9, 5);
      expect(DataHelpers.dateKey(date), '2026-09-05');
      expect(DataHelpers.todayKey(), matches(r'^\d{4}-\d{2}-\d{2}$'));
    });

    test('shortDateLabel formats month name and day correctly', () {
      expect(DataHelpers.shortDateLabel(DateTime(2026, 6, 16)), 'Jun 16');
      expect(DataHelpers.shortDateLabel(DateTime(2026, 1, 1)), 'Jan 1');
      expect(DataHelpers.shortDateLabel(null), '');
    });

    test('relativeDateLabel handles Today, Yesterday, and specific dates', () {
      final now = DateTime.now();
      expect(DataHelpers.relativeDateLabel(now), 'Today');

      final yesterday = now.subtract(const Duration(days: 1));
      expect(DataHelpers.relativeDateLabel(yesterday), 'Yesterday');
    });

    test('timestampToDate extracts DateTime safely', () {
      final sample = DateTime(2026, 9, 21, 10, 0);
      final timestamp = Timestamp.fromDate(sample);

      expect(DataHelpers.timestampToDate(timestamp), sample);
      expect(DataHelpers.timestampToDate('not-a-timestamp'), isNull);
      expect(DataHelpers.timestampToDate(null), isNull);
    });

    test('safePercentage guards against divide by zero', () {
      expect(DataHelpers.safePercentage(50, 100), 50.0);
      expect(DataHelpers.safePercentage(0, 100), 0.0);
      expect(DataHelpers.safePercentage(50, 0), 0.0);
      expect(DataHelpers.safePercentage(50, -10), 0.0);
    });

    test('formatCurrency formats money with prefix and commas', () {
      expect(DataHelpers.formatCurrency(4500), 'Rs. 4,500');
      expect(DataHelpers.formatCurrency(1500000), 'Rs. 1,500,000');
      expect(DataHelpers.formatCurrency(0), 'Rs. 0');
      expect(DataHelpers.formatCurrency(null), 'Rs. 0');
      expect(
        DataHelpers.formatCurrency(250.75, prefix: '\$', decimalDigits: 2),
        '\$250.75',
      );
    });

    test('truncateWithEllipsis handles string clipping properly', () {
      expect(DataHelpers.truncateWithEllipsis('Short', 10), 'Short');
      expect(
        DataHelpers.truncateWithEllipsis('The quick brown fox jumps over', 15),
        'The quick br...',
      );
      expect(DataHelpers.truncateWithEllipsis('', 5), '');
      expect(DataHelpers.truncateWithEllipsis(null, 5), '');
      expect(DataHelpers.truncateWithEllipsis('Hello', 3), 'Hel');
    });

    test('titleCase capitalizes words properly', () {
      expect(DataHelpers.titleCase('computer science'), 'Computer Science');
      expect(DataHelpers.titleCase('GRADE 10 - A'), 'Grade 10 - A');
      expect(DataHelpers.titleCase(''), '');
      expect(DataHelpers.titleCase(null), '');
    });
  });
}
