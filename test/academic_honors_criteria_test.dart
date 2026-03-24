import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/academic_honors_criteria.dart';

void main() {
  group('AcademicHonorsCriteria Tests', () {
    test('evaluateHonors evaluates high performing students', () {
      expect(
        AcademicHonorsCriteria.evaluateHonors(3.95, 92.0),
        'Summa Cum Laude (Highest Honors)',
      );
      expect(
        AcademicHonorsCriteria.evaluateHonors(3.80, 88.0),
        'Magna Cum Laude (High Honors)',
      );
      expect(
        AcademicHonorsCriteria.evaluateHonors(3.55, 86.0),
        'Cum Laude (Honors)',
      );
    });

    test('evaluateHonors disqualifies students with sub-85% attendance', () {
      expect(AcademicHonorsCriteria.evaluateHonors(4.0, 75.0), isNull);
    });

    test('qualifiesForDeansList enforces both GPA and presence thresholds', () {
      expect(AcademicHonorsCriteria.qualifiesForDeansList(3.70, 90.0), isTrue);
      expect(AcademicHonorsCriteria.qualifiesForDeansList(3.40, 95.0), isFalse);
    });
  });
}
