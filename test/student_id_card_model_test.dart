import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/student_id_card_model.dart';

void main() {
  group('StudentIdCardModel Tests', () {
    test('isExpired detects validity state accurately', () {
      final card = StudentIdCardModel(
        id: 'c1',
        studentId: 'std10',
        studentName: 'Hamza Ali',
        rollNumber: '2026-CS-01',
        className: '10-A',
        barcodeNumber: '890123456789',
        issueDate: DateTime(2026, 1, 1),
        expiryDate: DateTime(2026, 12, 31),
      );

      expect(card.isExpired(DateTime(2026, 6, 1)), isFalse);
      expect(card.isExpired(DateTime(2027, 1, 1)), isTrue);
    });

    test('serialization roundtrip preserves barcode identifier', () {
      final map = {
        'studentId': 'std20',
        'studentName': 'Sara Ahmed',
        'rollNumber': '2026-CS-20',
        'className': '9-B',
        'barcodeNumber': '998877665544',
        'issueDate': DateTime(2026, 1, 1).toIso8601String(),
        'expiryDate': DateTime(2026, 12, 31).toIso8601String(),
        'isValid': true,
      };

      final model = StudentIdCardModel.fromMap('c20', map);
      expect(model.barcodeNumber, '998877665544');
      expect(model.isValid, isTrue);
    });
  });
}
