/// Represents a specific chapter or topic within an academic course curriculum.
class SyllabusTopicModel {
  final String id;
  final String subject;
  final String className;
  final String chapterNumber;
  final String topicTitle;
  final int totalLessons;
  final int completedLessons;
  final bool isCompleted;

  const SyllabusTopicModel({
    required this.id,
    required this.subject,
    required this.className,
    required this.chapterNumber,
    required this.topicTitle,
    this.totalLessons = 1,
    this.completedLessons = 0,
    this.isCompleted = false,
  });

  factory SyllabusTopicModel.fromMap(String id, Map<String, dynamic> map) {
    return SyllabusTopicModel(
      id: id,
      subject: map['subject'] as String? ?? '',
      className: map['className'] as String? ?? '',
      chapterNumber: map['chapterNumber'] as String? ?? '1',
      topicTitle: map['topicTitle'] as String? ?? '',
      totalLessons: (map['totalLessons'] as num?)?.toInt() ?? 1,
      completedLessons: (map['completedLessons'] as num?)?.toInt() ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'className': className,
      'chapterNumber': chapterNumber,
      'topicTitle': topicTitle,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'isCompleted': isCompleted,
    };
  }

  /// Calculates percentage completion of this syllabus topic.
  double get progressPercentage {
    if (totalLessons <= 0) return isCompleted ? 100.0 : 0.0;
    final percentage = (completedLessons / totalLessons) * 100.0;
    return double.parse(percentage.clamp(0.0, 100.0).toStringAsFixed(1));
  }

  SyllabusTopicModel copyWith({
    String? id,
    String? subject,
    String? className,
    String? chapterNumber,
    String? topicTitle,
    int? totalLessons,
    int? completedLessons,
    bool? isCompleted,
  }) {
    return SyllabusTopicModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      className: className ?? this.className,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      topicTitle: topicTitle ?? this.topicTitle,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyllabusTopicModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          subject == other.subject &&
          chapterNumber == other.chapterNumber &&
          topicTitle == other.topicTitle;

  @override
  int get hashCode =>
      id.hashCode ^ subject.hashCode ^ chapterNumber.hashCode ^ topicTitle.hashCode;

  @override
  String toString() =>
      'SyllabusTopicModel(Ch.$chapterNumber: $topicTitle [$completedLessons/$totalLessons])';
}
