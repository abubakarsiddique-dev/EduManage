import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/security_clearance_levels.dart';

void main() {
  group('SecurityClearanceLevels Tests', () {
    test('getClearance assigns expected hierarchy weights', () {
      expect(SecurityClearanceLevels.getClearance('super_admin'), SecurityClearanceLevels.superAdmin);
      expect(SecurityClearanceLevels.getClearance('teacher'), SecurityClearanceLevels.teacher);
      expect(SecurityClearanceLevels.getClearance('guest'), SecurityClearanceLevels.guest);
    });

    test('hasClearance guards sensitive administrative routes', () {
      expect(SecurityClearanceLevels.hasClearance('superadmin', SecurityClearanceLevels.principal), isTrue);
      expect(SecurityClearanceLevels.hasClearance('teacher', SecurityClearanceLevels.superAdmin), isFalse);
      expect(SecurityClearanceLevels.hasClearance('teacher', SecurityClearanceLevels.teacher), isTrue);
    });
  });
}
