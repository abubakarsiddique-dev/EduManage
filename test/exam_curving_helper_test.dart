import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/exam_curving_helper.dart';

void main() {
  group('ExamCurvingHelper Tests', () {
    test('applySquareRootCurve enhances lower scores proportionally', () {
      expect(ExamCurvingHelper.applySquareRootCurve(64.0), 80.0);
      expect(ExamCurvingHelper.applySquareRootCurve(100.0), 100.0);
      expect(ExamCurvingHelper.applySquareRootCurve(0.0), 0.0);
    });

    test('applyAnchorToMax boosts all students up to maxScore ceiling', () {
      // Top score was 80/100, boost is 20
      expect(ExamCurvingHelper.applyAnchorToMax(65.0, 80.0), 85.0);
      expect(ExamCurvingHelper.applyAnchorToMax(80.0, 80.0), 100.0);
    });

    test('applyLinearBoost clamps at maxScore', () {
      expect(ExamCurvingHelper.applyLinearBoost(95.0, 10.0), 100.0);
    });
  });
}
