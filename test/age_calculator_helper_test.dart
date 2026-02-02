import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/age_calculator_helper.dart';

void main() {
  group('AgeCalculatorHelper Tests', () {
    test('calculateYears evaluates completed years correctly', () {
      final dob = DateTime(2010, 5, 15);
      final asOf = DateTime(2026, 2, 2);
      expect(AgeCalculatorHelper.calculateYears(dob, asOf), 15);

      final birthdayNotReachedYet = DateTime(2010, 5, 15);
      final beforeBirthday = DateTime(2026, 4, 1);
      expect(AgeCalculatorHelper.calculateYears(birthdayNotReachedYet, beforeBirthday), 15);
    });

    test('isEligibleForGrade checks age eligibility for admission', () {
      final dob = DateTime(2020, 1, 10);
      final sessionStart = DateTime(2026, 4, 1);
      expect(AgeCalculatorHelper.isEligibleForGrade(dob, 5, sessionStart), isTrue);
      expect(AgeCalculatorHelper.isEligibleForGrade(dob, 7, sessionStart), isFalse);
    });
  });
}
