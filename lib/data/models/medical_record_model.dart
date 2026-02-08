/// Represents a student's confidential medical profile, blood group, allergies, and emergency directives.
class MedicalRecordModel {
  final String id;
  final String studentId;
  final String bloodGroup; // 'A+', 'B+', 'O-', etc.
  final List<String> allergies;
  final List<String> chronicConditions;
  final String emergencyDoctorName;
  final String emergencyDoctorPhone;
  final String specialInstructions;

  const MedicalRecordModel({
    required this.id,
    required this.studentId,
    required this.bloodGroup,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.emergencyDoctorName = '',
    this.emergencyDoctorPhone = '',
    this.specialInstructions = '',
  });

  factory MedicalRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      bloodGroup: map['bloodGroup'] as String? ?? 'Unknown',
      allergies: (map['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      chronicConditions: (map['chronicConditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      emergencyDoctorName: map['emergencyDoctorName'] as String? ?? '',
      emergencyDoctorPhone: map['emergencyDoctorPhone'] as String? ?? '',
      specialInstructions: map['specialInstructions'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'emergencyDoctorName': emergencyDoctorName,
      'emergencyDoctorPhone': emergencyDoctorPhone,
      'specialInstructions': specialInstructions,
    };
  }

  bool get hasAllergies => allergies.isNotEmpty;
  bool get hasChronicConditions => chronicConditions.isNotEmpty;

  MedicalRecordModel copyWith({
    String? id,
    String? studentId,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? chronicConditions,
    String? emergencyDoctorName,
    String? emergencyDoctorPhone,
    String? specialInstructions,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      emergencyDoctorName: emergencyDoctorName ?? this.emergencyDoctorName,
      emergencyDoctorPhone: emergencyDoctorPhone ?? this.emergencyDoctorPhone,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          bloodGroup == other.bloodGroup;

  @override
  int get hashCode => id.hashCode ^ studentId.hashCode ^ bloodGroup.hashCode;

  @override
  String toString() => 'MedicalRecordModel(studentId: $studentId, bloodGroup: $bloodGroup)';
}
