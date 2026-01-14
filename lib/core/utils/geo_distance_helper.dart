import 'dart:math' as math;

/// Computes geographic distances between campus facilities and bus stops using Haversine formula.
class GeoDistanceHelper {
  GeoDistanceHelper._();

  static const double earthRadiusKm = 6371.0;

  /// Calculates the great-circle distance between two GPS coordinates in kilometers.
  static double distanceBetweenKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rLat1) * math.cos(rLat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    final distance = earthRadiusKm * c;
    return double.parse(distance.toStringAsFixed(2));
  }

  /// Calculates distance in meters.
  static double distanceBetweenMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return double.parse((distanceBetweenKm(lat1, lon1, lat2, lon2) * 1000).toStringAsFixed(1));
  }

  /// Checks if a student or bus location is within a geofenced radius (in meters) of a campus coordinate.
  static bool isWithinRadius(
    double currentLat,
    double currentLon,
    double centerLat,
    double centerLon,
    double radiusMeters,
  ) {
    final distanceMeters = distanceBetweenMeters(currentLat, currentLon, centerLat, centerLon);
    return distanceMeters <= radiusMeters;
  }

  static double _toRadians(double degree) => degree * (math.pi / 180.0);
}
