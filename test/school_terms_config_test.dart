import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/school_terms_config.dart';

void main() {
  group('SchoolTermsConfig Tests', () {
    test('getActiveTerm identifies spring semester', () {
      final springDate = DateTime(2026, 2, 21);
      final term = SchoolTermsConfig.getActiveTerm(springDate);
      expect(term, isNotNull);
      expect(term?.termId, 'spring_2026');
      expect(term?.termName, 'Spring Semester 2026');
    });

    test('getActiveTerm identifies fall semester', () {
      final fallDate = DateTime(2026, 10, 10);
      final term = SchoolTermsConfig.getActiveTerm(fallDate);
      expect(term?.termId, 'fall_2026');
    });

    test('getActiveTerm returns null during winter vacation gap', () {
      final vacation = DateTime(2026, 1, 5);
      final term = SchoolTermsConfig.getActiveTerm(vacation);
      expect(term, isNull);
    });
  });
}
