import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/geo_distance_helper.dart';

void main() {
  group('GeoDistanceHelper Tests', () {
    test('distanceBetweenKm returns 0 for identical coordinates', () {
      expect(GeoDistanceHelper.distanceBetweenKm(31.5204, 74.3587, 31.5204, 74.3587), 0.0);
    });

    test('distanceBetweenKm computes realistic distance', () {
      // Distance between Lahore (31.5204, 74.3587) and Islamabad (33.6844, 73.0479) is ~260-270 km
      final dist = GeoDistanceHelper.distanceBetweenKm(31.5204, 74.3587, 33.6844, 73.0479);
      expect(dist, greaterThan(250.0));
      expect(dist, lessThan(300.0));
    });

    test('isWithinRadius checks geofence perimeter', () {
      const centerLat = 31.5204;
      const centerLon = 74.3587;
      // Exact same point is within 100 meters
      expect(GeoDistanceHelper.isWithinRadius(centerLat, centerLon, centerLat, centerLon, 100), isTrue);
      // Point 50km away is not within 500 meters
      expect(GeoDistanceHelper.isWithinRadius(31.9000, 74.3587, centerLat, centerLon, 500), isFalse);
    });
  });
}
