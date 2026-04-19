import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackStatus { pending, reviewed, resolved }

/// Represents an inquiry or feedback message submitted by a parent.
class ParentFeedbackModel {
  final String id;
  final String parentId;
  final String parentName;
  final String studentId;
  final String studentName;
  final String subject;
  final String message;
  final FeedbackStatus status;
  final String? adminResponse;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const ParentFeedbackModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.studentId,
    this.studentName = '',
    required this.subject,
    required this.message,
    this.status = FeedbackStatus.pending,
    this.adminResponse,
    this.createdAt,
    this.resolvedAt,
  });

  factory ParentFeedbackModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    FeedbackStatus parseStatus(String? str) {
      switch (str?.toLowerCase().trim()) {
        case 'reviewed':
          return FeedbackStatus.reviewed;
        case 'resolved':
          return FeedbackStatus.resolved;
        default:
          return FeedbackStatus.pending;
      }
    }

    return ParentFeedbackModel(
      id: id,
      parentId: map['parentId'] as String? ?? '',
      parentName: map['parentName'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: parseStatus(map['status'] as String?),
      adminResponse: map['adminResponse'] as String?,
      createdAt: parseDate(map['createdAt']),
      resolvedAt: parseDate(map['resolvedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    String statusString(FeedbackStatus s) {
      switch (s) {
        case FeedbackStatus.reviewed:
          return 'reviewed';
        case FeedbackStatus.resolved:
          return 'resolved';
        case FeedbackStatus.pending:
          return 'pending';
      }
    }

    return {
      'parentId': parentId,
      'parentName': parentName,
      'studentId': studentId,
      'studentName': studentName,
      'subject': subject,
      'message': message,
      'status': statusString(status),
      if (adminResponse != null) 'adminResponse': adminResponse,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
    };
  }

  bool get isPending => status == FeedbackStatus.pending;
  bool get isResolved => status == FeedbackStatus.resolved;

  ParentFeedbackModel copyWith({
    String? id,
    String? parentId,
    String? parentName,
    String? studentId,
    String? studentName,
    String? subject,
    String? message,
    FeedbackStatus? status,
    String? adminResponse,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ParentFeedbackModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParentFeedbackModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          parentId == other.parentId &&
          subject == other.subject &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^ parentId.hashCode ^ subject.hashCode ^ status.hashCode;

  @override
  String toString() =>
      'ParentFeedbackModel(id: $id, parent: $parentName, subject: $subject, status: $status)';
}
