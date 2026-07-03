import 'dart:math' as math;

/// Curving models for adjusting tough exam distributions.
enum CurvingMethod { anchorToMax, linearBoost, squareRoot }

/// Helper for adjusting student assessment scores using recognized psychometric curving algorithms.
class ExamCurvingHelper {
  ExamCurvingHelper._();

  /// Applies square-root curve: $Score_{new} = 10 \times \sqrt{Score_{raw}}$
  static double applySquareRootCurve(double rawScore, [double maxScore = 100.0]) {
    if (rawScore <= 0) return 0.0;
    if (maxScore != 100.0) {
      final normalized = (rawScore / maxScore) * 100.0;
      final curvedNormalized = 10.0 * math.sqrt(normalized);
      final rescaled = (curvedNormalized / 100.0) * maxScore;
      return double.parse(rescaled.clamp(0.0, maxScore).toStringAsFixed(1));
    }
    final curved = 10.0 * math.sqrt(rawScore);
    return double.parse(curved.clamp(0.0, 100.0).toStringAsFixed(1));
  }

  /// Anchors highest class score to maximum possible score (e.g. if top score is 85/100, add 15 points to all).
  static double applyAnchorToMax(double rawScore, double highestInCohort, [double maxScore = 100.0]) {
    if (highestInCohort <= 0 || highestInCohort >= maxScore) return rawScore;
    final boost = maxScore - highestInCohort;
    final curved = rawScore + boost;
    return double.parse(curved.clamp(0.0, maxScore).toStringAsFixed(1));
  }

  /// Adds a flat linear boost percentage clamped at maximum score.
  static double applyLinearBoost(double rawScore, double flatPoints, [double maxScore = 100.0]) {
    final curved = rawScore + flatPoints;
    return double.parse(curved.clamp(0.0, maxScore).toStringAsFixed(1));
  }
}
