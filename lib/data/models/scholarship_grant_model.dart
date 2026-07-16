enum ScholarshipType { merit, needBased, sports, siblingConcession }

/// Represents a tuition discount, scholarship award, or fee concession granted to a student.
class ScholarshipGrantModel {
  final String id;
  final String studentId;
  final String studentName;
  final ScholarshipType scholarshipType;
  final double discountPercentage; // e.g. 50.0 for 50% discount
  final String approvedBy;
  final DateTime effectiveFrom;
  final DateTime expiresAt;
  final bool isActive;

  const ScholarshipGrantModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.scholarshipType,
    required this.discountPercentage,
    required this.approvedBy,
    required this.effectiveFrom,
    required this.expiresAt,
    this.isActive = true,
  });

  factory ScholarshipGrantModel.fromMap(String id, Map<String, dynamic> map) {
    ScholarshipType parseType(String? str) {
      switch (str?.toLowerCase().trim()) {
        case 'need_based':
        case 'needbased':
          return ScholarshipType.needBased;
        case 'sports':
          return ScholarshipType.sports;
        case 'sibling':
        case 'sibling_concession':
          return ScholarshipType.siblingConcession;
        default:
          return ScholarshipType.merit;
      }
    }

    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    return ScholarshipGrantModel(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      scholarshipType: parseType(map['scholarshipType'] as String?),
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      approvedBy: map['approvedBy'] as String? ?? '',
      effectiveFrom: parseDate(map['effectiveFrom']),
      expiresAt: parseDate(map['expiresAt']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    String typeToString(ScholarshipType t) {
      switch (t) {
        case ScholarshipType.needBased:
          return 'need_based';
        case ScholarshipType.sports:
          return 'sports';
        case ScholarshipType.siblingConcession:
          return 'sibling_concession';
        case ScholarshipType.merit:
          return 'merit';
      }
    }

    return {
      'studentId': studentId,
      'studentName': studentName,
      'scholarshipType': typeToString(scholarshipType),
      'discountPercentage': discountPercentage,
      'approvedBy': approvedBy,
      'effectiveFrom': effectiveFrom.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Calculates net tuition fee after applying scholarship concession.
  double calculateNetFee(double baseFee) {
    if (!isActive || discountPercentage <= 0) return baseFee;
    final discount = (baseFee * (discountPercentage / 100.0));
    return double.parse((baseFee - discount).clamp(0.0, baseFee).toStringAsFixed(0));
  }

  ScholarshipGrantModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    ScholarshipType? scholarshipType,
    double? discountPercentage,
    String? approvedBy,
    DateTime? effectiveFrom,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return ScholarshipGrantModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      scholarshipType: scholarshipType ?? this.scholarshipType,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      approvedBy: approvedBy ?? this.approvedBy,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScholarshipGrantModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          discountPercentage == other.discountPercentage;

  @override
  int get hashCode => id.hashCode ^ studentId.hashCode ^ discountPercentage.hashCode;

  @override
  String toString() =>
      'ScholarshipGrantModel(student: $studentName, discount: $discountPercentage%)';
}
