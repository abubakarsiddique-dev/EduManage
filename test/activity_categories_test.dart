import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/activity_categories.dart';

void main() {
  group('ActivityCategories Tests', () {
    test('all contains expected standard societies', () {
      expect(ActivityCategories.all.contains(ActivityCategories.sports), isTrue);
      expect(ActivityCategories.all.contains(ActivityCategories.scienceAndTech), isTrue);
      expect(ActivityCategories.isValidCategory(ActivityCategories.literaryAndDebate), isTrue);
      expect(ActivityCategories.isValidCategory('Unauthorized Club'), isFalse);
    });
  });
}
