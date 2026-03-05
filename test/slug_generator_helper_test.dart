import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/slug_generator_helper.dart';

void main() {
  group('SlugGeneratorHelper Tests', () {
    test('generate cleans special characters and spaces', () {
      expect(
        SlugGeneratorHelper.generate('Chapter 3: Thermodynamics & Heat!'),
        'chapter-3-thermodynamics-heat',
      );
      expect(
        SlugGeneratorHelper.generate('   Annual Sports Gala 2026   '),
        'annual-sports-gala-2026',
      );
      expect(SlugGeneratorHelper.generate(''), '');
    });
  });
}
