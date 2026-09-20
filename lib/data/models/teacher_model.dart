import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a document in the `teachers` collection.
class TeacherModel {
  final String id; // == Firebase Auth uid
  final String name;
  final String email;
  final String phone;
  final String subject;
  final String qualification;
  final List<String> classes;
  final bool approved;
  final DateTime? createdAt;

  bool get isApproved => approved;

  const TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.qualification,
    required this.classes,
    this.approved = true,
    this.createdAt,
  });

  factory TeacherModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return TeacherModel(
      id: id,
      name: map['name'] as String? ?? 'Unknown',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      subject: map['subject'] as String? ?? '-',
      qualification: map['qualification'] as String? ?? '-',
      classes:
          (map['classes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      approved: map['approved'] as bool? ?? true,
      createdAt: parseDate(map['createdAt']),
    );
  }

  factory TeacherModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TeacherModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'qualification': qualification,
      'classes': classes,
      'approved': approved,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Returns a comma-separated list of assigned classes for UI display.
  String get classesFormatted =>
      classes.isEmpty ? 'No classes assigned' : classes.join(', ');

  TeacherModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? subject,
    String? qualification,
    List<String>? classes,
    bool? approved,
    DateTime? createdAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subject: subject ?? this.subject,
      qualification: qualification ?? this.qualification,
      classes: classes ?? this.classes,
      approved: approved ?? this.approved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          subject == other.subject &&
          qualification == other.qualification &&
          approved == other.approved &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        phone,
        subject,
        qualification,
        approved,
        createdAt,
      );

  @override
  String toString() =>
      'TeacherModel(id: $id, name: $name, subject: $subject, email: $email)';
}

