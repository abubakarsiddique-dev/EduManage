import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/medical_record_model.dart';

void main() {
  group('MedicalRecordModel Tests', () {
    test('hasAllergies detects presence of allergic triggers', () {
      const record = MedicalRecordModel(
        id: 'med1',
        studentId: 'std10',
        bloodGroup: 'B+',
        allergies: ['Peanuts', 'Penicillin'],
      );
      expect(record.hasAllergies, isTrue);
      expect(record.hasChronicConditions, isFalse);
    });

    test('serialization roundtrip preserves emergency details', () {
      final map = {
        'studentId': 'std15',
        'bloodGroup': 'O+',
        'allergies': ['Dust'],
        'chronicConditions': ['Asthma'],
        'emergencyDoctorName': 'Dr. Farooq',
        'emergencyDoctorPhone': '+923005551234',
        'specialInstructions': 'Keep inhaler accessible during PE',
      };

      final model = MedicalRecordModel.fromMap('med15', map);
      expect(model.bloodGroup, 'O+');
      expect(model.hasChronicConditions, isTrue);
      expect(model.specialInstructions, 'Keep inhaler accessible during PE');
    });
  });
}
