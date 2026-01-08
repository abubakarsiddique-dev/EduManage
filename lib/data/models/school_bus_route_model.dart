/// Represents a school bus transport route with stops and driver details.
class SchoolBusRouteModel {
  final String id;
  final String routeNumber;
  final String routeName;
  final String driverName;
  final String driverPhone;
  final String vehicleRegistration;
  final int capacity;
  final List<String> stops;
  final bool isActive;

  const SchoolBusRouteModel({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleRegistration,
    required this.capacity,
    this.stops = const [],
    this.isActive = true,
  });

  factory SchoolBusRouteModel.fromMap(String id, Map<String, dynamic> map) {
    return SchoolBusRouteModel(
      id: id,
      routeNumber: map['routeNumber'] as String? ?? '',
      routeName: map['routeName'] as String? ?? '',
      driverName: map['driverName'] as String? ?? '',
      driverPhone: map['driverPhone'] as String? ?? '',
      vehicleRegistration: map['vehicleRegistration'] as String? ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 30,
      stops: (map['stops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routeNumber': routeNumber,
      'routeName': routeName,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleRegistration': vehicleRegistration,
      'capacity': capacity,
      'stops': stops,
      'isActive': isActive,
    };
  }

  int get totalStops => stops.length;
  bool containsStop(String stopName) =>
      stops.any((s) => s.toLowerCase().contains(stopName.toLowerCase()));

  SchoolBusRouteModel copyWith({
    String? id,
    String? routeNumber,
    String? routeName,
    String? driverName,
    String? driverPhone,
    String? vehicleRegistration,
    int? capacity,
    List<String>? stops,
    bool? isActive,
  }) {
    return SchoolBusRouteModel(
      id: id ?? this.id,
      routeNumber: routeNumber ?? this.routeNumber,
      routeName: routeName ?? this.routeName,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      capacity: capacity ?? this.capacity,
      stops: stops ?? this.stops,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolBusRouteModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          routeNumber == other.routeNumber &&
          vehicleRegistration == other.vehicleRegistration;

  @override
  int get hashCode => id.hashCode ^ routeNumber.hashCode ^ vehicleRegistration.hashCode;

  @override
  String toString() => 'SchoolBusRouteModel(route: $routeNumber, name: $routeName)';
}
