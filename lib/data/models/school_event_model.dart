import 'package:cloud_firestore/cloud_firestore.dart';

enum EventAudience { all, studentsOnly, parentsOnly, teachersOnly }

/// Represents a campus event, assembly, sports gala, or parent-teacher conference.
class SchoolEventModel {
  final String id;
  final String title;
  final String description;
  final String venue;
  final DateTime startDate;
  final DateTime endDate;
  final EventAudience audience;
  final bool isMandatory;

  const SchoolEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.startDate,
    required this.endDate,
    this.audience = EventAudience.all,
    this.isMandatory = false,
  });

  factory SchoolEventModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    EventAudience parseAudience(String? str) {
      switch (str?.toLowerCase().trim()) {
        case 'students':
        case 'students_only':
          return EventAudience.studentsOnly;
        case 'parents':
        case 'parents_only':
          return EventAudience.parentsOnly;
        case 'teachers':
        case 'teachers_only':
          return EventAudience.teachersOnly;
        default:
          return EventAudience.all;
      }
    }

    return SchoolEventModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      venue: map['venue'] as String? ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      audience: parseAudience(map['audience'] as String?),
      isMandatory: map['isMandatory'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    String audienceToString(EventAudience a) {
      switch (a) {
        case EventAudience.studentsOnly:
          return 'students';
        case EventAudience.parentsOnly:
          return 'parents';
        case EventAudience.teachersOnly:
          return 'teachers';
        case EventAudience.all:
          return 'all';
      }
    }

    return {
      'title': title,
      'description': description,
      'venue': venue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'audience': audienceToString(audience),
      'isMandatory': isMandatory,
    };
  }

  bool isUpcoming([DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    return startDate.isAfter(now);
  }

  bool isHappeningNow([DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    return (now.isAfter(startDate) || now.isAtSameMomentAs(startDate)) &&
        (now.isBefore(endDate) || now.isAtSameMomentAs(endDate));
  }

  SchoolEventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? venue,
    DateTime? startDate,
    DateTime? endDate,
    EventAudience? audience,
    bool? isMandatory,
  }) {
    return SchoolEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      venue: venue ?? this.venue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      audience: audience ?? this.audience,
      isMandatory: isMandatory ?? this.isMandatory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolEventModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          venue == other.venue;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ venue.hashCode;

  @override
  String toString() => 'SchoolEventModel(title: $title, venue: $venue)';
}
