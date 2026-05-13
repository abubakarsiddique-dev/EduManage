enum ConsentStatus { pending, granted, declined }

/// Represents an electronic parental consent authorization for field trips, sports, or medical checkups.
class ParentConsentFormModel {
  final String id;
  final String title;
  final String studentId;
  final String parentId;
  final String eventDetails;
  final DateTime deadline;
  final ConsentStatus status;
  final DateTime? signedAt;

  const ParentConsentFormModel({
    required this.id,
    required this.title,
    required this.studentId,
    required this.parentId,
    required this.eventDetails,
    required this.deadline,
    this.status = ConsentStatus.pending,
    this.signedAt,
  });

  factory ParentConsentFormModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    ConsentStatus parseStatus(String? str) {
      switch (str?.toLowerCase().trim()) {
        case 'granted':
          return ConsentStatus.granted;
        case 'declined':
          return ConsentStatus.declined;
        default:
          return ConsentStatus.pending;
      }
    }

    return ParentConsentFormModel(
      id: id,
      title: map['title'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      parentId: map['parentId'] as String? ?? '',
      eventDetails: map['eventDetails'] as String? ?? '',
      deadline: parseDate(map['deadline']),
      status: parseStatus(map['status'] as String?),
      signedAt: map['signedAt'] != null ? parseDate(map['signedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    String statusToString(ConsentStatus s) {
      switch (s) {
        case ConsentStatus.granted:
          return 'granted';
        case ConsentStatus.declined:
          return 'declined';
        case ConsentStatus.pending:
          return 'pending';
      }
    }

    return {
      'title': title,
      'studentId': studentId,
      'parentId': parentId,
      'eventDetails': eventDetails,
      'deadline': deadline.toIso8601String(),
      'status': statusToString(status),
      if (signedAt != null) 'signedAt': signedAt!.toIso8601String(),
    };
  }

  bool get isGranted => status == ConsentStatus.granted;
  bool get isPending => status == ConsentStatus.pending;

  ParentConsentFormModel copyWith({
    String? id,
    String? title,
    String? studentId,
    String? parentId,
    String? eventDetails,
    DateTime? deadline,
    ConsentStatus? status,
    DateTime? signedAt,
  }) {
    return ParentConsentFormModel(
      id: id ?? this.id,
      title: title ?? this.title,
      studentId: studentId ?? this.studentId,
      parentId: parentId ?? this.parentId,
      eventDetails: eventDetails ?? this.eventDetails,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      signedAt: signedAt ?? this.signedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentConsentFormModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ studentId.hashCode ^ status.hashCode;

  @override
  String toString() => 'ParentConsentFormModel(title: $title, status: $status)';
}
