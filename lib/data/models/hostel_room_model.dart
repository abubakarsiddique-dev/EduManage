/// Represents a student boarding dormitory room with occupancy tracking.
class HostelRoomModel {
  final String id;
  final String roomNumber;
  final String hostelBlock; // 'Boys Hostel A' | 'Girls Hostel B'
  final int capacity;
  final int occupiedBeds;
  final double monthlyRent;
  final bool hasAttachedBath;
  final bool hasAirConditioning;

  const HostelRoomModel({
    required this.id,
    required this.roomNumber,
    required this.hostelBlock,
    required this.capacity,
    this.occupiedBeds = 0,
    required this.monthlyRent,
    this.hasAttachedBath = true,
    this.hasAirConditioning = false,
  });

  factory HostelRoomModel.fromMap(String id, Map<String, dynamic> map) {
    return HostelRoomModel(
      id: id,
      roomNumber: map['roomNumber'] as String? ?? '',
      hostelBlock: map['hostelBlock'] as String? ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 2,
      occupiedBeds: (map['occupiedBeds'] as num?)?.toInt() ?? 0,
      monthlyRent: (map['monthlyRent'] as num?)?.toDouble() ?? 15000.0,
      hasAttachedBath: map['hasAttachedBath'] as bool? ?? true,
      hasAirConditioning: map['hasAirConditioning'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'hostelBlock': hostelBlock,
      'capacity': capacity,
      'occupiedBeds': occupiedBeds,
      'monthlyRent': monthlyRent,
      'hasAttachedBath': hasAttachedBath,
      'hasAirConditioning': hasAirConditioning,
    };
  }

  bool get isFull => occupiedBeds >= capacity;
  int get vacantBeds => (capacity - occupiedBeds).clamp(0, capacity);

  HostelRoomModel copyWith({
    String? id,
    String? roomNumber,
    String? hostelBlock,
    int? capacity,
    int? occupiedBeds,
    double? monthlyRent,
    bool? hasAttachedBath,
    bool? hasAirConditioning,
  }) {
    return HostelRoomModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      hostelBlock: hostelBlock ?? this.hostelBlock,
      capacity: capacity ?? this.capacity,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      hasAttachedBath: hasAttachedBath ?? this.hasAttachedBath,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostelRoomModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          roomNumber == other.roomNumber &&
          hostelBlock == other.hostelBlock;

  @override
  int get hashCode => id.hashCode ^ roomNumber.hashCode ^ hostelBlock.hashCode;

  @override
  String toString() => 'HostelRoomModel($hostelBlock - Room $roomNumber [$occupiedBeds/$capacity])';
}
