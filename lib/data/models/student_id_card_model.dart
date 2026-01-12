/// Represents a student digital identity card with security barcode and validity dates.
class StudentIdCardModel {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String className;
  final String barcodeNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final bool isValid;

  const StudentIdCardModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.barcodeNumber,
    required this.issueDate,
    required this.expiryDate,
    this.isValid = true,
  });

  factory StudentIdCardModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    return StudentIdCardModel(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      rollNumber: map['rollNumber'] as String? ?? '',
      className: map['className'] as String? ?? '',
      barcodeNumber: map['barcodeNumber'] as String? ?? '',
      issueDate: parseDate(map['issueDate']),
      expiryDate: parseDate(map['expiryDate']),
      isValid: map['isValid'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'className': className,
      'barcodeNumber': barcodeNumber,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'isValid': isValid,
    };
  }

  bool isExpired([DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    return now.isAfter(expiryDate);
  }

  StudentIdCardModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? rollNumber,
    String? className,
    String? barcodeNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    bool? isValid,
  }) {
    return StudentIdCardModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      className: className ?? this.className,
      barcodeNumber: barcodeNumber ?? this.barcodeNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentIdCardModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          barcodeNumber == other.barcodeNumber;

  @override
  int get hashCode => id.hashCode ^ barcodeNumber.hashCode;

  @override
  String toString() => 'StudentIdCardModel(roll: $rollNumber, student: $studentName)';
}
