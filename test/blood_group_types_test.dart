import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/blood_group_types.dart';

void main() {
  group('BloodGroupTypes Tests', () {
    test('all contains exactly 8 standard ABO/Rh blood groups', () {
      expect(BloodGroupTypes.all.length, 8);
      expect(BloodGroupTypes.isValid('A+'), isTrue);
      expect(BloodGroupTypes.isValid('Z+'), isFalse);
    });

    test('donor and recipient predicates identify correct groups', () {
      expect(BloodGroupTypes.isUniversalDonor('O-'), isTrue);
      expect(BloodGroupTypes.isUniversalDonor('O+'), isFalse);
      expect(BloodGroupTypes.isUniversalRecipient('AB+'), isTrue);
      expect(BloodGroupTypes.isUniversalRecipient('B+'), isFalse);
    });
  });
}
