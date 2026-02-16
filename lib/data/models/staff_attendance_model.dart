import 'package:cloud_firestore/cloud_firestore.dart';

enum StaffAttendanceStatus { present, lateArrival, halfDay, absent, onLeave }

/// Records daily check-in and check-out logs for teachers and school staff.
class StaffAttendanceModel {
  final String id;
  final String staffId;
  final String staffName;
  final String role; // 'teacher' | 'admin' | 'staff'
  final DateTime date;
  final String checkInTime; // '07:55'
  final String? checkOutTime; // '15:00'
  final StaffAttendanceStatus status;
  final String remarks;

  const StaffAttendanceModel({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.role,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.status = StaffAttendanceStatus.present,
    this.remarks = '',
  });

  factory StaffAttendanceModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    StaffAttendanceStatus parseStatus(String? str) {
      switch (str?.toLowerCase().trim()) {
        case 'late_arrival':
        case 'late':
          return StaffAttendanceStatus.lateArrival;
        case 'half_day':
          return StaffAttendanceStatus.halfDay;
        case 'absent':
          return StaffAttendanceStatus.absent;
        case 'on_leave':
          return StaffAttendanceStatus.onLeave;
        default:
          return StaffAttendanceStatus.present;
      }
    }

    return StaffAttendanceModel(
      id: id,
      staffId: map['staffId'] as String? ?? '',
      staffName: map['staffName'] as String? ?? '',
      role: map['role'] as String? ?? 'teacher',
      date: parseDate(map['date']),
      checkInTime: map['checkInTime'] as String? ?? '',
      checkOutTime: map['checkOutTime'] as String?,
      status: parseStatus(map['status'] as String?),
      remarks: map['remarks'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    String statusToString(StaffAttendanceStatus s) {
      switch (s) {
        case StaffAttendanceStatus.lateArrival:
          return 'late_arrival';
        case StaffAttendanceStatus.halfDay:
          return 'half_day';
        case StaffAttendanceStatus.absent:
          return 'absent';
        case StaffAttendanceStatus.onLeave:
          return 'on_leave';
        case StaffAttendanceStatus.present:
          return 'present';
      }
    }

    return {
      'staffId': staffId,
      'staffName': staffName,
      'role': role,
      'date': Timestamp.fromDate(date),
      'checkInTime': checkInTime,
      if (checkOutTime != null) 'checkOutTime': checkOutTime,
      'status': statusToString(status),
      'remarks': remarks,
    };
  }

  bool get isPunctual => status == StaffAttendanceStatus.present;

  /// Calculates total hours worked if checkOutTime is recorded.
  double get totalHoursWorked {
    if (checkOutTime == null || checkInTime.isEmpty) return 0.0;
    try {
      final inParts = checkInTime.split(':').map(int.parse).toList();
      final outParts = checkOutTime!.split(':').map(int.parse).toList();
      final inMinutes = inParts[0] * 60 + inParts[1];
      final outMinutes = outParts[0] * 60 + outParts[1];
      final diff = outMinutes - inMinutes;
      if (diff <= 0) return 0.0;
      return double.parse((diff / 60.0).toStringAsFixed(1));
    } catch (_) {
      return 0.0;
    }
  }

  StaffAttendanceModel copyWith({
    String? id,
    String? staffId,
    String? staffName,
    String? role,
    DateTime? date,
    String? checkInTime,
    String? checkOutTime,
    StaffAttendanceStatus? status,
    String? remarks,
  }) {
    return StaffAttendanceModel(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      role: role ?? this.role,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffAttendanceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          staffId == other.staffId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode => id.hashCode ^ staffId.hashCode ^ date.day.hashCode;

  @override
  String toString() => 'StaffAttendanceModel(staff: $staffName, status: $status)';
}
