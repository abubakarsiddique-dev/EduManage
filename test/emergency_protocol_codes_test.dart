import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/emergency_protocol_codes.dart';

void main() {
  group('EmergencyProtocolCodes Tests', () {
    test('getDirective returns precise emergency instruction', () {
      expect(
        EmergencyProtocolCodes.getDirective(EmergencyProtocolCodes.codeRed).contains('Lock all classroom doors'),
        isTrue,
      );
      expect(
        EmergencyProtocolCodes.getDirective(EmergencyProtocolCodes.drillFire).contains('Evacuate systematically'),
        isTrue,
      );
      expect(
        EmergencyProtocolCodes.getDirective('UNKNOWN_CODE', 'Custom guidance'),
        'Custom guidance',
      );
    });
  });
}
