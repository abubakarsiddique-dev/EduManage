import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/roll_number_generator.dart';

void main() {
  group('RollNumberGenerator Tests', () {
    test('generate builds standardized roll number format', () {
      final roll = RollNumberGenerator.generate(
        academicYear: 2026,
        programCode: 'CS',
        sequenceNumber: 42,
      );
      expect(roll, '2026-CS-0042');
    });

    test('parse decomposes roll number string into components', () {
      final (year, program, sequence) = RollNumberGenerator.parse('2026-SE-0105');
      expect(year, 2026);
      expect(program, 'SE');
      expect(sequence, 105);
    });
  });
}
