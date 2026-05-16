/// Represents a physical room or facility on campus (lecture hall, science lab, library).
class ClassroomFacilityModel {
  final String id;
  final String roomNumber;
  final String building;
  final int capacity;
  final String facilityType; // 'Classroom' | 'Science Lab' | 'Computer Lab' | 'Auditorium'
  final bool hasProjector;
  final bool hasAirConditioning;
  final bool isAvailable;

  const ClassroomFacilityModel({
    required this.id,
    required this.roomNumber,
    required this.building,
    required this.capacity,
    this.facilityType = 'Classroom',
    this.hasProjector = false,
    this.hasAirConditioning = false,
    this.isAvailable = true,
  });

  factory ClassroomFacilityModel.fromMap(String id, Map<String, dynamic> map) {
    return ClassroomFacilityModel(
      id: id,
      roomNumber: map['roomNumber'] as String? ?? '',
      building: map['building'] as String? ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 30,
      facilityType: map['facilityType'] as String? ?? 'Classroom',
      hasProjector: map['hasProjector'] as bool? ?? false,
      hasAirConditioning: map['hasAirConditioning'] as bool? ?? false,
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'building': building,
      'capacity': capacity,
      'facilityType': facilityType,
      'hasProjector': hasProjector,
      'hasAirConditioning': hasAirConditioning,
      'isAvailable': isAvailable,
    };
  }

  String get displayName => '$building - $roomNumber ($facilityType)';

  ClassroomFacilityModel copyWith({
    String? id,
    String? roomNumber,
    String? building,
    int? capacity,
    String? facilityType,
    bool? hasProjector,
    bool? hasAirConditioning,
    bool? isAvailable,
  }) {
    return ClassroomFacilityModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
      facilityType: facilityType ?? this.facilityType,
      hasProjector: hasProjector ?? this.hasProjector,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassroomFacilityModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          roomNumber == other.roomNumber &&
          building == other.building &&
          capacity == other.capacity;

  @override
  int get hashCode =>
      id.hashCode ^ roomNumber.hashCode ^ building.hashCode ^ capacity.hashCode;

  @override
  String toString() => 'ClassroomFacilityModel(room: $roomNumber, building: $building)';
}
