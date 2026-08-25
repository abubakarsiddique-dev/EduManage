import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/campus_building_map.dart';

void main() {
  group('CampusBuildingMap Tests', () {
    test('findByCode resolves valid building metadata', () {
      final b = CampusBuildingMap.findByCode('SCI');
      expect(b, isNotNull);
      expect(b?.buildingName, 'Ibn-e-Sina Science Block');
      expect(b?.departments.contains('Physics Lab'), isTrue);
    });

    test('findByCode returns null for nonexistent code', () {
      expect(CampusBuildingMap.findByCode('XYZ'), isNull);
    });
  });
}
