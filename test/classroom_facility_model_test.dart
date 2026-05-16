import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/classroom_facility_model.dart';

void main() {
  group('ClassroomFacilityModel Tests', () {
    test('displayName creates readable string', () {
      const room = ClassroomFacilityModel(
        id: 'r1',
        roomNumber: '101',
        building: 'Science Block',
        capacity: 45,
        facilityType: 'Science Lab',
      );
      expect(room.displayName, 'Science Block - 101 (Science Lab)');
    });

    test('serialization roundtrip preserves state', () {
      final map = {
        'roomNumber': '204',
        'building': 'Main Hall',
        'capacity': 60,
        'facilityType': 'Classroom',
        'hasProjector': true,
        'hasAirConditioning': true,
        'isAvailable': true,
      };
      final model = ClassroomFacilityModel.fromMap('r204', map);
      expect(model.hasProjector, isTrue);
      expect(model.capacity, 60);

      final exported = model.toMap();
      expect(exported['hasAirConditioning'], isTrue);
    });
  });
}
