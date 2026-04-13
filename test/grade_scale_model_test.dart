import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/grade_scale_model.dart';

void main() {
  group('GradeScaleModel Tests', () {
    test('standardScale contains expected progression', () {
      expect(GradeScaleModel.standardScale.isNotEmpty, isTrue);
      expect(GradeScaleModel.standardScale.first.grade, 'A+');
      expect(GradeScaleModel.standardScale.first.gpaPoints, 4.0);
    });

    test('isScoreInRange accurately matches scores', () {
      final gradeA = GradeScaleModel.standardScale.firstWhere((s) => s.grade == 'A+');
      expect(gradeA.isScoreInRange(95), isTrue);
      expect(gradeA.isScoreInRange(89), isFalse);
    });

    test('serialization roundtrip preserves all fields', () {
      const model = GradeScaleModel(
        grade: 'A',
        gpaPoints: 3.7,
        minScore: 85,
        maxScore: 89.99,
        description: 'Excellent',
      );
      final map = model.toMap();
      final restored = GradeScaleModel.fromMap(map);
      expect(restored, equals(model));
    });
  });
}
