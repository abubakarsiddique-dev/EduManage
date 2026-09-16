import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/utils/exam_assessment_engine.dart';

void main() {
  group('ExamAssessmentEngine Test Suite', () {
    test('computeStatistics calculates mean, median, min, max, and pass rate', () {
      final scores = [60.0, 70.0, 80.0, 90.0, 100.0];
      final stats = ExamAssessmentEngine.computeStatistics(scores, passingScoreThreshold: 75.0);

      expect(stats.count, 5);
      expect(stats.mean, 80.0);
      expect(stats.median, 80.0);
      expect(stats.min, 60.0);
      expect(stats.max, 100.0);
      expect(stats.passingCount, 3); // 80, 90, 100
      expect(stats.passingRate, 60.0);
      expect(stats.interquartileRange, greaterThan(0));
    });

    test('computeStatistics handles empty scores gracefully', () {
      final stats = ExamAssessmentEngine.computeStatistics([]);
      expect(stats.count, 0);
      expect(stats.mean, 0.0);
      expect(stats.passingRate, 0.0);
      expect(stats.modes, isEmpty);
    });

    test('computeStatistics correctly discovers multiple modes', () {
      final scores = [50.0, 60.0, 60.0, 75.0, 75.0, 90.0];
      final stats = ExamAssessmentEngine.computeStatistics(scores);

      expect(stats.modes, containsAll([60.0, 75.0]));
      expect(stats.modes.length, 2);
    });

    test('calculateZScore and calculateTScore produce accurate standard scores', () {
      // Mean = 70, StdDev = 10, Score = 90 -> Z = +2.0
      final z = ExamAssessmentEngine.calculateZScore(90.0, 70.0, 10.0);
      expect(z, 2.0);

      // T-score = 50 + 10 * 2.0 = 70.0
      final t = ExamAssessmentEngine.calculateTScore(z);
      expect(t, 70.0);

      // Zero standard deviation does not divide by zero
      final zZero = ExamAssessmentEngine.calculateZScore(80.0, 80.0, 0.0);
      expect(zZero, 0.0);
    });

    test('calculatePercentileRank determines mid-rank percentile accurately', () {
      final distribution = [10.0, 20.0, 30.0, 40.0, 50.0];

      // Score 10: 0 lower, 1 equal -> (0 + 0.5) / 5 * 100 = 10%
      final pct10 = ExamAssessmentEngine.calculatePercentileRank(10.0, distribution);
      expect(pct10, 10.0);

      // Score 50: 4 lower, 1 equal -> (4 + 0.5) / 5 * 100 = 90%
      final pct50 = ExamAssessmentEngine.calculatePercentileRank(50.0, distribution);
      expect(pct50, 90.0);
    });

    test('CurvingStrategy.none returns uncurved raw scores and letter grades', () {
      final entries = [
        const AssessmentScore(studentId: 's1', studentName: 'Alice', rawScore: 88, maxScore: 100),
        const AssessmentScore(studentId: 's2', studentName: 'Bob', rawScore: 42, maxScore: 100),
      ];

      final curved = ExamAssessmentEngine.applyCurving(
        entries: entries,
        strategy: CurvingStrategy.none,
      );

      expect(curved[0].curvedScore, 88);
      expect(curved[0].letterGrade, 'A');
      expect(curved[1].curvedScore, 42);
      expect(curved[1].letterGrade, 'D');
    });

    test('CurvingStrategy.anchorToMax scales top score to targetMax', () {
      // Highest score is 80/100 -> scaled to 100 (multiplier 1.25)
      final entries = [
        const AssessmentScore(studentId: 's1', studentName: 'Alice', rawScore: 80, maxScore: 100),
        const AssessmentScore(studentId: 's2', studentName: 'Bob', rawScore: 40, maxScore: 100),
      ];

      final curved = ExamAssessmentEngine.applyCurving(
        entries: entries,
        strategy: CurvingStrategy.anchorToMax,
        targetMax: 100.0,
      );

      expect(curved[0].curvedScore, closeTo(100.0, 0.01));
      expect(curved[1].curvedScore, closeTo(50.0, 0.01));
    });

    test('CurvingStrategy.linearBoost adds flat points capped at 100', () {
      final entries = [
        const AssessmentScore(studentId: 's1', studentName: 'Alice', rawScore: 97, maxScore: 100),
        const AssessmentScore(studentId: 's2', studentName: 'Bob', rawScore: 60, maxScore: 100),
      ];

      final curved = ExamAssessmentEngine.applyCurving(
        entries: entries,
        strategy: CurvingStrategy.linearBoost,
        linearBoostAmount: 5.0,
      );

      expect(curved[0].curvedScore, 100.0); // Capped at 100
      expect(curved[1].curvedScore, 65.0);
    });

    test('CurvingStrategy.squareRoot scales fairly via 10*sqrt(score)', () {
      final entries = [
        const AssessmentScore(studentId: 's1', studentName: 'Alice', rawScore: 64, maxScore: 100),
        const AssessmentScore(studentId: 's2', studentName: 'Bob', rawScore: 100, maxScore: 100),
      ];

      final curved = ExamAssessmentEngine.applyCurving(
        entries: entries,
        strategy: CurvingStrategy.squareRoot,
      );

      // 10 * sqrt(64) = 80.0
      expect(curved[0].curvedScore, closeTo(80.0, 0.01));
      expect(curved[1].curvedScore, closeTo(100.0, 0.01));
    });

    test('CurvingStrategy.bellCurve assigns relative Gaussian letter grades', () {
      // 5 spread-out scores
      final entries = [
        const AssessmentScore(studentId: 's1', studentName: 'Top', rawScore: 95, maxScore: 100),
        const AssessmentScore(studentId: 's2', studentName: 'High', rawScore: 80, maxScore: 100),
        const AssessmentScore(studentId: 's3', studentName: 'Mid', rawScore: 65, maxScore: 100),
        const AssessmentScore(studentId: 's4', studentName: 'Low', rawScore: 50, maxScore: 100),
        const AssessmentScore(studentId: 's5', studentName: 'Bottom', rawScore: 30, maxScore: 100),
      ];

      final curved = ExamAssessmentEngine.applyCurving(
        entries: entries,
        strategy: CurvingStrategy.bellCurve,
      );

      expect(curved.first.letterGrade, isIn(['A', 'B']));
      expect(curved.last.letterGrade, isIn(['D', 'F']));
    });

    test('aggregateWeightedScore computes composite weighted average', () {
      final components = [
        const AssessmentComponent(name: 'Quizzes', weight: 20.0, earnedScore: 18.0, maxScore: 20.0), // 90%
        const AssessmentComponent(name: 'Midterm', weight: 30.0, earnedScore: 80.0, maxScore: 100.0), // 80%
        const AssessmentComponent(name: 'Final', weight: 50.0, earnedScore: 90.0, maxScore: 100.0), // 90%
      ];

      // Contribution: (0.9 * 20) + (0.8 * 30) + (0.9 * 50) = 18 + 24 + 45 = 87.0
      final composite = ExamAssessmentEngine.aggregateWeightedScore(components);
      expect(composite, closeTo(87.0, 0.01));
    });

    test('resolveAcademicStanding assigns honors and warning classifications correctly', () {
      expect(
        ExamAssessmentEngine.resolveAcademicStanding(95.0),
        AcademicStanding.summaCumLaude,
      );
      expect(
        ExamAssessmentEngine.resolveAcademicStanding(89.0),
        AcademicStanding.magnaCumLaude,
      );
      expect(
        ExamAssessmentEngine.resolveAcademicStanding(83.0),
        AcademicStanding.cumLaude,
      );
      expect(
        ExamAssessmentEngine.resolveAcademicStanding(72.0),
        AcademicStanding.goodStanding,
      );
      expect(
        ExamAssessmentEngine.resolveAcademicStanding(55.0),
        AcademicStanding.academicWarning,
      );
      expect(
        ExamAssessmentEngine.resolveAcademicStanding(35.0),
        AcademicStanding.academicProbation,
      );
    });

    test('percentageToLetterGrade covers full range from A+ to F', () {
      expect(ExamAssessmentEngine.percentageToLetterGrade(95.0), 'A+');
      expect(ExamAssessmentEngine.percentageToLetterGrade(86.0), 'A');
      expect(ExamAssessmentEngine.percentageToLetterGrade(81.0), 'A-');
      expect(ExamAssessmentEngine.percentageToLetterGrade(76.0), 'B+');
      expect(ExamAssessmentEngine.percentageToLetterGrade(71.0), 'B');
      expect(ExamAssessmentEngine.percentageToLetterGrade(66.0), 'B-');
      expect(ExamAssessmentEngine.percentageToLetterGrade(61.0), 'C+');
      expect(ExamAssessmentEngine.percentageToLetterGrade(56.0), 'C');
      expect(ExamAssessmentEngine.percentageToLetterGrade(51.0), 'C-');
      expect(ExamAssessmentEngine.percentageToLetterGrade(42.0), 'D');
      expect(ExamAssessmentEngine.percentageToLetterGrade(30.0), 'F');
    });
  });
}
