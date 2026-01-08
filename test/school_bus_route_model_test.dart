import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/school_bus_route_model.dart';

void main() {
  group('SchoolBusRouteModel Tests', () {
    test('stops counting and search functionality', () {
      const route = SchoolBusRouteModel(
        id: 'r1',
        routeNumber: 'Route-5',
        routeName: 'North Campus Shuttle',
        driverName: 'Mr. Tariq',
        driverPhone: '+923001234567',
        vehicleRegistration: 'LEA-2024',
        capacity: 40,
        stops: ['Main Gate', 'City Center', 'Gulberg', 'Model Town'],
      );

      expect(route.totalStops, 4);
      expect(route.containsStop('Gulberg'), isTrue);
      expect(route.containsStop('DHA'), isFalse);
    });

    test('serialization roundtrip preserves state', () {
      final map = {
        'routeNumber': 'Route-12',
        'routeName': 'South Route',
        'driverName': 'Aslam Khan',
        'driverPhone': '+923119876543',
        'vehicleRegistration': 'LXZ-9988',
        'capacity': 50,
        'stops': ['Stop A', 'Stop B'],
        'isActive': true,
      };

      final model = SchoolBusRouteModel.fromMap('r12', map);
      expect(model.routeNumber, 'Route-12');
      expect(model.capacity, 50);

      final exported = model.toMap();
      expect(exported['driverName'], 'Aslam Khan');
    });
  });
}
