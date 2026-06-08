enum BookingStatus { pending, approved, rejected, cancelled }

/// Represents an authorized reservation for school facilities (auditorium, computer lab, sports field).
class FacilityBookingModel {
  final String id;
  final String facilityName;
  final String requestedBy;
  final String userRole; // 'teacher' | 'student_council' | 'admin'
  final DateTime bookingDate;
  final String startTime; // '10:00'
  final String endTime;   // '12:00'
  final String purpose;
  final BookingStatus status;

  const FacilityBookingModel({
    required this.id,
    required this.facilityName,
    required this.requestedBy,
    required this.userRole,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    this.status = BookingStatus.pending,
  });

  factory FacilityBookingModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    BookingStatus parseStatus(String? str) {
      switch (str?.toLowerCase().trim()) {
        case 'approved':
          return BookingStatus.approved;
        case 'rejected':
          return BookingStatus.rejected;
        case 'cancelled':
          return BookingStatus.cancelled;
        default:
          return BookingStatus.pending;
      }
    }

    return FacilityBookingModel(
      id: id,
      facilityName: map['facilityName'] as String? ?? '',
      requestedBy: map['requestedBy'] as String? ?? '',
      userRole: map['userRole'] as String? ?? 'teacher',
      bookingDate: parseDate(map['bookingDate']),
      startTime: map['startTime'] as String? ?? '08:00',
      endTime: map['endTime'] as String? ?? '09:00',
      purpose: map['purpose'] as String? ?? '',
      status: parseStatus(map['status'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    String statusToString(BookingStatus s) {
      switch (s) {
        case BookingStatus.approved:
          return 'approved';
        case BookingStatus.rejected:
          return 'rejected';
        case BookingStatus.cancelled:
          return 'cancelled';
        case BookingStatus.pending:
          return 'pending';
      }
    }

    return {
      'facilityName': facilityName,
      'requestedBy': requestedBy,
      'userRole': userRole,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'purpose': purpose,
      'status': statusToString(status),
    };
  }

  bool get isApproved => status == BookingStatus.approved;
  bool get isPending => status == BookingStatus.pending;

  FacilityBookingModel copyWith({
    String? id,
    String? facilityName,
    String? requestedBy,
    String? userRole,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    String? purpose,
    BookingStatus? status,
  }) {
    return FacilityBookingModel(
      id: id ?? this.id,
      facilityName: facilityName ?? this.facilityName,
      requestedBy: requestedBy ?? this.requestedBy,
      userRole: userRole ?? this.userRole,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacilityBookingModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          facilityName == other.facilityName &&
          bookingDate.year == other.bookingDate.year &&
          bookingDate.month == other.bookingDate.month &&
          bookingDate.day == other.bookingDate.day &&
          startTime == other.startTime;

  @override
  int get hashCode => id.hashCode ^ facilityName.hashCode ^ startTime.hashCode;

  @override
  String toString() =>
      'FacilityBookingModel(facility: $facilityName, by: $requestedBy, status: $status)';
}
