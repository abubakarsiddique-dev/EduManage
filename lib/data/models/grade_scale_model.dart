/// Represents an academic grading tier with associated GPA points and score bounds.
class GradeScaleModel {
  final String grade;
  final double gpaPoints;
  final double minScore;
  final double maxScore;
  final String description;

  const GradeScaleModel({
    required this.grade,
    required this.gpaPoints,
    required this.minScore,
    required this.maxScore,
    this.description = '',
  });

  factory GradeScaleModel.fromMap(Map<String, dynamic> map) {
    return GradeScaleModel(
      grade: map['grade'] as String? ?? 'F',
      gpaPoints: (map['gpaPoints'] as num?)?.toDouble() ?? 0.0,
      minScore: (map['minScore'] as num?)?.toDouble() ?? 0.0,
      maxScore: (map['maxScore'] as num?)?.toDouble() ?? 100.0,
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'gpaPoints': gpaPoints,
      'minScore': minScore,
      'maxScore': maxScore,
      'description': description,
    };
  }

  bool isScoreInRange(double score) => score >= minScore && score <= maxScore;

  GradeScaleModel copyWith({
    String? grade,
    double? gpaPoints,
    double? minScore,
    double? maxScore,
    String? description,
  }) {
    return GradeScaleModel(
      grade: grade ?? this.grade,
      gpaPoints: gpaPoints ?? this.gpaPoints,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeScaleModel &&
          runtimeType == other.runtimeType &&
          grade == other.grade &&
          gpaPoints == other.gpaPoints &&
          minScore == other.minScore &&
          maxScore == other.maxScore &&
          description == other.description;

  @override
  int get hashCode =>
      grade.hashCode ^
      gpaPoints.hashCode ^
      minScore.hashCode ^
      maxScore.hashCode ^
      description.hashCode;

  @override
  String toString() =>
      'GradeScaleModel(grade: $grade, gpaPoints: $gpaPoints, range: $minScore-$maxScore)';

  /// Standard reference grading scale used by default.
  static const List<GradeScaleModel> standardScale = [
    GradeScaleModel(grade: 'A+', gpaPoints: 4.0, minScore: 90, maxScore: 100, description: 'Outstanding'),
    GradeScaleModel(grade: 'A', gpaPoints: 3.7, minScore: 85, maxScore: 89.99, description: 'Excellent'),
    GradeScaleModel(grade: 'B+', gpaPoints: 3.3, minScore: 80, maxScore: 84.99, description: 'Very Good'),
    GradeScaleModel(grade: 'B', gpaPoints: 3.0, minScore: 75, maxScore: 79.99, description: 'Good'),
    GradeScaleModel(grade: 'C', gpaPoints: 2.5, minScore: 65, maxScore: 74.99, description: 'Satisfactory'),
    GradeScaleModel(grade: 'D', gpaPoints: 2.0, minScore: 50, maxScore: 64.99, description: 'Pass'),
    GradeScaleModel(grade: 'F', gpaPoints: 0.0, minScore: 0, maxScore: 49.99, description: 'Fail'),
  ];
}
