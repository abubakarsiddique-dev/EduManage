import 'dart:math' as math;

/// Types of mathematical curving strategies applicable to cohort scores.
enum CurvingStrategy {
  none,
  anchorToMax,
  linearBoost,
  squareRoot,
  bellCurve,
}

/// Evaluation honors and academic status classifications.
enum AcademicStanding {
  summaCumLaude,
  magnaCumLaude,
  cumLaude,
  goodStanding,
  academicWarning,
  academicProbation,
}

/// Represents an individual student's assessment performance and standardized metrics.
class AssessmentScore {
  final String studentId;
  final String studentName;
  final double rawScore;
  final double maxScore;
  final double? curvedScore;
  final String? letterGrade;
  final double? percentile;
  final double? zScore;
  final double? tScore;

  const AssessmentScore({
    required this.studentId,
    required this.studentName,
    required this.rawScore,
    required this.maxScore,
    this.curvedScore,
    this.letterGrade,
    this.percentile,
    this.zScore,
    this.tScore,
  });

  /// Percentage score calculated from raw performance.
  double get percentage => maxScore > 0 ? (rawScore / maxScore) * 100.0 : 0.0;

  /// Effective percentage using curved score if available, otherwise raw percentage.
  double get effectivePercentage => maxScore > 0
      ? ((curvedScore ?? rawScore) / maxScore) * 100.0
      : 0.0;

  AssessmentScore copyWith({
    double? curvedScore,
    String? letterGrade,
    double? percentile,
    double? zScore,
    double? tScore,
  }) {
    return AssessmentScore(
      studentId: studentId,
      studentName: studentName,
      rawScore: rawScore,
      maxScore: maxScore,
      curvedScore: curvedScore ?? this.curvedScore,
      letterGrade: letterGrade ?? this.letterGrade,
      percentile: percentile ?? this.percentile,
      zScore: zScore ?? this.zScore,
      tScore: tScore ?? this.tScore,
    );
  }

  @override
  String toString() =>
      'AssessmentScore($studentName: ${rawScore.toStringAsFixed(1)}/$maxScore, Grade: $letterGrade)';
}

/// Comprehensive statistical summary for an exam or assessment cohort.
class CohortStatistics {
  final int count;
  final double mean;
  final double median;
  final List<double> modes;
  final double standardDeviation;
  final double variance;
  final double min;
  final double max;
  final double q1;
  final double q3;
  final double interquartileRange;
  final int passingCount;
  final double passingRate;

  const CohortStatistics({
    required this.count,
    required this.mean,
    required this.median,
    required this.modes,
    required this.standardDeviation,
    required this.variance,
    required this.min,
    required this.max,
    required this.q1,
    required this.q3,
    required this.interquartileRange,
    required this.passingCount,
    required this.passingRate,
  });

  @override
  String toString() =>
      'CohortStatistics(Count: $count, Mean: ${mean.toStringAsFixed(2)}, Median: ${median.toStringAsFixed(2)}, StdDev: ${standardDeviation.toStringAsFixed(2)}, PassRate: ${passingRate.toStringAsFixed(1)}%)';
}

/// Weighted grading component such as Midterm, Quiz, or Final Exam.
class AssessmentComponent {
  final String name;
  final double weight; // Percentage e.g. 20.0 for 20%
  final double earnedScore;
  final double maxScore;

  const AssessmentComponent({
    required this.name,
    required this.weight,
    required this.earnedScore,
    required this.maxScore,
  });

  /// Contribution of this component to overall composite grade (0.0 to 100.0).
  double get weightedContribution {
    if (maxScore <= 0 || weight <= 0) return 0.0;
    final ratio = (earnedScore / maxScore).clamp(0.0, 1.0);
    return ratio * weight;
  }
}

/// Core intelligence engine for statistical exam evaluation, standard scoring, and grade curving.
class ExamAssessmentEngine {
  /// Computes comprehensive statistical distribution metrics for a list of numeric scores.
  static CohortStatistics computeStatistics(
    List<double> scores, {
    double passingScoreThreshold = 50.0,
  }) {
    if (scores.isEmpty) {
      return const CohortStatistics(
        count: 0,
        mean: 0.0,
        median: 0.0,
        modes: [],
        standardDeviation: 0.0,
        variance: 0.0,
        min: 0.0,
        max: 0.0,
        q1: 0.0,
        q3: 0.0,
        interquartileRange: 0.0,
        passingCount: 0,
        passingRate: 0.0,
      );
    }

    final sorted = List<double>.from(scores)..sort();
    final count = sorted.length;
    final sum = sorted.reduce((a, b) => a + b);
    final mean = sum / count;

    // Median
    final double median = count.isOdd
        ? sorted[count ~/ 2]
        : (sorted[(count ~/ 2) - 1] + sorted[count ~/ 2]) / 2.0;

    // Mode(s)
    final Map<double, int> frequencies = {};
    for (final val in sorted) {
      frequencies[val] = (frequencies[val] ?? 0) + 1;
    }
    int maxFreq = 0;
    for (final f in frequencies.values) {
      if (f > maxFreq) maxFreq = f;
    }
    final List<double> modes = [];
    if (maxFreq > 1) {
      for (final entry in frequencies.entries) {
        if (entry.value == maxFreq) {
          modes.add(entry.key);
        }
      }
    }

    // Variance & Sample Standard Deviation
    double varianceSum = 0.0;
    for (final val in sorted) {
      varianceSum += math.pow(val - mean, 2);
    }
    final variance = count > 1 ? varianceSum / (count - 1) : 0.0;
    final stdDev = math.sqrt(variance);

    // Quartiles
    final q1 = _computePercentileValue(sorted, 0.25);
    final q3 = _computePercentileValue(sorted, 0.75);
    final iqr = q3 - q1;

    // Passing Metrics
    final passingCount =
        sorted.where((score) => score >= passingScoreThreshold).length;
    final passingRate = (passingCount / count) * 100.0;

    return CohortStatistics(
      count: count,
      mean: mean,
      median: median,
      modes: modes,
      standardDeviation: stdDev,
      variance: variance,
      min: sorted.first,
      max: sorted.last,
      q1: q1,
      q3: q3,
      interquartileRange: iqr,
      passingCount: passingCount,
      passingRate: passingRate,
    );
  }

  /// Calculates the standard Z-Score: (score - mean) / standardDeviation.
  static double calculateZScore(double score, double mean, double stdDev) {
    if (stdDev <= 0.00001) return 0.0;
    return (score - mean) / stdDev;
  }

  /// Calculates the standardized T-Score: 50.0 + 10.0 * Z-Score.
  static double calculateTScore(double zScore) {
    return 50.0 + (10.0 * zScore);
  }

  /// Computes the percentile rank of a score within a reference distribution (0.0 to 100.0).
  static double calculatePercentileRank(double target, List<double> allScores) {
    if (allScores.isEmpty) return 0.0;
    int countLower = 0;
    int countEqual = 0;

    for (final s in allScores) {
      if (s < target) {
        countLower++;
      } else if ((s - target).abs() < 0.00001) {
        countEqual++;
      }
    }

    // Standard mid-rank percentile formula: (countLower + 0.5 * countEqual) / total * 100
    final rank = ((countLower + (0.5 * countEqual)) / allScores.length) * 100.0;
    return rank.clamp(0.0, 100.0);
  }

  /// Applies mathematical curving to a cohort of assessment scores.
  static List<AssessmentScore> applyCurving({
    required List<AssessmentScore> entries,
    required CurvingStrategy strategy,
    double targetMax = 100.0,
    double linearBoostAmount = 5.0,
  }) {
    if (entries.isEmpty) return [];

    final rawScores = entries.map((e) => e.percentage).toList();
    final stats = computeStatistics(rawScores);

    switch (strategy) {
      case CurvingStrategy.none:
        return entries.map((entry) {
          final z = calculateZScore(entry.percentage, stats.mean, stats.standardDeviation);
          final t = calculateTScore(z);
          final pct = calculatePercentileRank(entry.percentage, rawScores);
          final grade = percentageToLetterGrade(entry.percentage);
          return entry.copyWith(
            curvedScore: entry.rawScore,
            letterGrade: grade,
            percentile: pct,
            zScore: z,
            tScore: t,
          );
        }).toList();

      case CurvingStrategy.anchorToMax:
        final topPercentage = stats.max > 0 ? stats.max : 100.0;
        final multiplier = topPercentage > 0 ? (targetMax / topPercentage) : 1.0;

        return entries.map((entry) {
          final curvedPct = (entry.percentage * multiplier).clamp(0.0, targetMax);
          final curvedRaw = (curvedPct / 100.0) * entry.maxScore;
          final z = calculateZScore(curvedPct, stats.mean * multiplier, stats.standardDeviation * multiplier);
          final t = calculateTScore(z);
          final pct = calculatePercentileRank(entry.percentage, rawScores);
          return entry.copyWith(
            curvedScore: curvedRaw.clamp(0.0, entry.maxScore),
            letterGrade: percentageToLetterGrade(curvedPct),
            percentile: pct,
            zScore: z,
            tScore: t,
          );
        }).toList();

      case CurvingStrategy.linearBoost:
        return entries.map((entry) {
          final boostedPct = (entry.percentage + linearBoostAmount).clamp(0.0, 100.0);
          final curvedRaw = (boostedPct / 100.0) * entry.maxScore;
          final z = calculateZScore(entry.percentage, stats.mean, stats.standardDeviation);
          final t = calculateTScore(z);
          final pct = calculatePercentileRank(entry.percentage, rawScores);
          return entry.copyWith(
            curvedScore: curvedRaw.clamp(0.0, entry.maxScore),
            letterGrade: percentageToLetterGrade(boostedPct),
            percentile: pct,
            zScore: z,
            tScore: t,
          );
        }).toList();

      case CurvingStrategy.squareRoot:
        // Square Root curve formula: 10 * sqrt(rawPercentage)
        return entries.map((entry) {
          final curvedPct = (10.0 * math.sqrt(entry.percentage.clamp(0.0, 100.0))).clamp(0.0, 100.0);
          final curvedRaw = (curvedPct / 100.0) * entry.maxScore;
          final z = calculateZScore(entry.percentage, stats.mean, stats.standardDeviation);
          final t = calculateTScore(z);
          final pct = calculatePercentileRank(entry.percentage, rawScores);
          return entry.copyWith(
            curvedScore: curvedRaw.clamp(0.0, entry.maxScore),
            letterGrade: percentageToLetterGrade(curvedPct),
            percentile: pct,
            zScore: z,
            tScore: t,
          );
        }).toList();

      case CurvingStrategy.bellCurve:
        // Gaussian distribution grading
        return entries.map((entry) {
          final z = calculateZScore(entry.percentage, stats.mean, stats.standardDeviation);
          final t = calculateTScore(z);
          final pct = calculatePercentileRank(entry.percentage, rawScores);
          String bellGrade;
          if (z >= 1.5) {
            bellGrade = 'A';
          } else if (z >= 0.5) {
            bellGrade = 'B';
          } else if (z >= -0.5) {
            bellGrade = 'C';
          } else if (z >= -1.5) {
            bellGrade = 'D';
          } else {
            bellGrade = 'F';
          }

          return entry.copyWith(
            curvedScore: entry.rawScore,
            letterGrade: bellGrade,
            percentile: pct,
            zScore: z,
            tScore: t,
          );
        }).toList();
    }
  }

  /// Aggregates weighted course components into a unified composite percentage score.
  static double aggregateWeightedScore(List<AssessmentComponent> components) {
    if (components.isEmpty) return 0.0;
    double totalEarnedWeighted = 0.0;
    double totalWeight = 0.0;

    for (final comp in components) {
      totalEarnedWeighted += comp.weightedContribution;
      totalWeight += comp.weight;
    }

    if (totalWeight <= 0) return 0.0;
    // Normalize to 100% in case weights were partial
    return ((totalEarnedWeighted / totalWeight) * 100.0).clamp(0.0, 100.0);
  }

  /// Maps a numeric percentage to a standard institutional letter grade.
  static String percentageToLetterGrade(double percentage) {
    if (percentage >= 90.0) return 'A+';
    if (percentage >= 85.0) return 'A';
    if (percentage >= 80.0) return 'A-';
    if (percentage >= 75.0) return 'B+';
    if (percentage >= 70.0) return 'B';
    if (percentage >= 65.0) return 'B-';
    if (percentage >= 60.0) return 'C+';
    if (percentage >= 55.0) return 'C';
    if (percentage >= 50.0) return 'C-';
    if (percentage >= 40.0) return 'D';
    return 'F';
  }

  /// Resolves an overall score into academic honors or standing status.
  static AcademicStanding resolveAcademicStanding(double overallPercentage) {
    if (overallPercentage >= 93.0) return AcademicStanding.summaCumLaude;
    if (overallPercentage >= 88.0) return AcademicStanding.magnaCumLaude;
    if (overallPercentage >= 82.0) return AcademicStanding.cumLaude;
    if (overallPercentage >= 65.0) return AcademicStanding.goodStanding;
    if (overallPercentage >= 50.0) return AcademicStanding.academicWarning;
    return AcademicStanding.academicProbation;
  }

  /// Helper to compute percentile value using linear interpolation.
  static double _computePercentileValue(List<double> sorted, double p) {
    if (sorted.isEmpty) return 0.0;
    if (sorted.length == 1) return sorted.first;

    final index = p * (sorted.length - 1);
    final lower = index.floor();
    final upper = index.ceil();
    final weight = index - lower;

    if (lower == upper) return sorted[lower];
    return sorted[lower] * (1.0 - weight) + sorted[upper] * weight;
  }
}
