import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/scholarship_tiers.dart';

void main() {
  group('ScholarshipTiers Tests', () {
    test('getRecommendedDiscountForGpa maps top GPA bands to discounts', () {
      expect(ScholarshipTiers.getRecommendedDiscountForGpa(3.98), ScholarshipTiers.fullBright);
      expect(ScholarshipTiers.getRecommendedDiscountForGpa(3.88), ScholarshipTiers.presidentMerit);
      expect(ScholarshipTiers.getRecommendedDiscountForGpa(3.72), ScholarshipTiers.deanHonor);
      expect(ScholarshipTiers.getRecommendedDiscountForGpa(3.20), 0.0);
    });
  });
}
