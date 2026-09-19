import 'dart:math' as math;

/// Risk category for student attendance deficit.
enum AttendanceRiskLevel {
  low, // >= 85%
  moderate, // 75% - 84.9%
  high, // 65% - 74.9%
  critical, // < 65%
}

/// Baseline student attendance telemetry.
class AttendanceRecordSummary {
  final int totalClassesConducted;
  final int classesAttended;
  final int unexcusedAbsences;
  final int excusedAbsences;

  const AttendanceRecordSummary({
    required this.totalClassesConducted,
    required this.classesAttended,
    this.unexcusedAbsences = 0,
    this.excusedAbsences = 0,
  });

  /// Current historical attendance percentage.
  double get currentPercentage => totalClassesConducted > 0
      ? (classesAttended / totalClassesConducted) * 100.0
      : 100.0;
}

/// Predictive telemetry projecting future attendance thresholds and deficit recovery.
class AttendanceForecast {
  final double currentPercentage;
  final int remainingClasses;
  final double projectedBestCasePercentage;
  final double projectedWorstCasePercentage;
  final int maxAllowableFutureAbsences;
  final bool isInDeficit;
  final int recoveryClassesNeeded;
  final bool isRecoveryPossible;
  final AttendanceRiskLevel riskLevel;
  final double targetThreshold;

  const AttendanceForecast({
    required this.currentPercentage,
    required this.remainingClasses,
    required this.projectedBestCasePercentage,
    required this.projectedWorstCasePercentage,
    required this.maxAllowableFutureAbsences,
    required this.isInDeficit,
    required this.recoveryClassesNeeded,
    required this.isRecoveryPossible,
    required this.riskLevel,
    required this.targetThreshold,
  });

  @override
  String toString() =>
      'AttendanceForecast(Current: ${currentPercentage.toStringAsFixed(1)}%, MaxMissable: $maxAllowableFutureAbsences, RecoveryNeeded: $recoveryClassesNeeded, Risk: ${riskLevel.name})';
}

/// Result of evaluating a prospective leave request against future attendance.
class LeaveImpactAssessment {
  final int requestedLeaveDays;
  final double projectedPercentageAfterLeave;
  final bool breachesThreshold;
  final double percentageDrop;
  final String recommendation;

  const LeaveImpactAssessment({
    required this.requestedLeaveDays,
    required this.projectedPercentageAfterLeave,
    required this.breachesThreshold,
    required this.percentageDrop,
    required this.recommendation,
  });
}

/// Intelligence engine for attendance forecasting, margin-of-safety analysis, and leave impact projection.
class AttendanceForecastingEngine {
  /// Computes complete predictive forecast for a student's term attendance.
  static AttendanceForecast forecastAttendance({
    required int attended,
    required int totalConducted,
    required int remainingClasses,
    double mandatoryThreshold = 75.0,
  }) {
    final clampedAttended = attended.clamp(0, totalConducted);
    final currentPct = totalConducted > 0
        ? (clampedAttended / totalConducted) * 100.0
        : 100.0;

    final totalTermClasses = totalConducted + remainingClasses;
    final bestCaseAttended = clampedAttended + remainingClasses;
    final bestCasePct = totalTermClasses > 0
        ? (bestCaseAttended / totalTermClasses) * 100.0
        : 100.0;
    final worstCasePct = totalTermClasses > 0
        ? (clampedAttended / totalTermClasses) * 100.0
        : 100.0;

    // Calculate max allowable future absences to stay >= mandatoryThreshold
    // Condition: (attended + remaining - absences) / totalTermClasses >= threshold / 100
    // => remaining - absences >= (threshold / 100) * totalTermClasses - attended
    // => absences <= attended + remaining - (threshold / 100) * totalTermClasses
    final minAttendedRequired = (mandatoryThreshold / 100.0) * totalTermClasses;
    final maxMissableRaw =
        (clampedAttended + remainingClasses) - minAttendedRequired;
    final maxAllowableAbsences = maxMissableRaw < 0
        ? 0
        : math.min(remainingClasses, maxMissableRaw.floor());

    final isInDeficit = currentPct < mandatoryThreshold;

    // Recovery streak needed:
    // (attended + n) / (totalConducted + n) >= threshold / 100
    // n * (1 - threshold / 100) >= (threshold / 100) * totalConducted - attended
    int recoveryNeeded = 0;
    bool isRecoveryPossible = true;

    if (isInDeficit) {
      final thresholdRatio = mandatoryThreshold / 100.0;
      final denominator = 1.0 - thresholdRatio;
      if (denominator <= 0.0001) {
        recoveryNeeded = 9999;
        isRecoveryPossible = false;
      } else {
        final numerator = (thresholdRatio * totalConducted) - clampedAttended;
        recoveryNeeded = (numerator / denominator).ceil();
        if (recoveryNeeded < 0) recoveryNeeded = 0;
        isRecoveryPossible = recoveryNeeded <= remainingClasses;
      }
    }

    final riskLevel = resolveRiskLevel(currentPct);

    return AttendanceForecast(
      currentPercentage: currentPct,
      remainingClasses: remainingClasses,
      projectedBestCasePercentage: bestCasePct,
      projectedWorstCasePercentage: worstCasePct,
      maxAllowableFutureAbsences: maxAllowableAbsences,
      isInDeficit: isInDeficit,
      recoveryClassesNeeded: recoveryNeeded,
      isRecoveryPossible: isRecoveryPossible,
      riskLevel: riskLevel,
      targetThreshold: mandatoryThreshold,
    );
  }

  /// Evaluates the impact of a proposed leave request on a student's attendance.
  static LeaveImpactAssessment simulateLeaveImpact({
    required AttendanceRecordSummary summary,
    required int requestedLeaveDays,
    required int remainingClasses,
    double mandatoryThreshold = 75.0,
    bool isExcused = false,
  }) {
    if (requestedLeaveDays <= 0) {
      return LeaveImpactAssessment(
        requestedLeaveDays: 0,
        projectedPercentageAfterLeave: summary.currentPercentage,
        breachesThreshold: summary.currentPercentage < mandatoryThreshold,
        percentageDrop: 0.0,
        recommendation: 'Valid leave period (0 days requested)',
      );
    }

    // If excused and the institutional policy excludes excused absences from total denominator:
    // Or standard policy where attended does not increase while total increases:
    final totalConductedWithLeave =
        summary.totalClassesConducted + requestedLeaveDays;
    final attendedWithLeave = isExcused
        ? summary
              .classesAttended // excused absence does not award attendance
        : summary.classesAttended;

    final projectedPct = totalConductedWithLeave > 0
        ? (attendedWithLeave / totalConductedWithLeave) * 100.0
        : 100.0;

    final drop = summary.currentPercentage - projectedPct;
    final breaches = projectedPct < mandatoryThreshold;

    String recommendation;
    if (breaches) {
      recommendation =
          'CAUTION: Approving this leave drops attendance to ${projectedPct.toStringAsFixed(1)}%, violating the ${mandatoryThreshold.toStringAsFixed(0)}% threshold.';
    } else if (projectedPct < mandatoryThreshold + 5.0) {
      recommendation =
          'WARNING: Attendance will drop to ${projectedPct.toStringAsFixed(1)}%, near the critical safety margin.';
    } else {
      recommendation =
          'APPROVED: Student retains a healthy buffer of ${projectedPct.toStringAsFixed(1)}%.';
    }

    return LeaveImpactAssessment(
      requestedLeaveDays: requestedLeaveDays,
      projectedPercentageAfterLeave: projectedPct,
      breachesThreshold: breaches,
      percentageDrop: math.max(0.0, drop),
      recommendation: recommendation,
    );
  }

  /// Calculates attendance velocity / trend across a recent rolling session history.
  /// Returns +1 for improving trend, -1 for deteriorating trend, 0 for stable.
  static int calculateTrajectoryTrend(List<bool> recentHistory) {
    if (recentHistory.length < 4) return 0;

    final midpoint = recentHistory.length ~/ 2;
    final firstHalf = recentHistory.sublist(0, midpoint);
    final secondHalf = recentHistory.sublist(midpoint);

    final firstRate = firstHalf.where((p) => p).length / firstHalf.length;
    final secondRate = secondHalf.where((p) => p).length / secondHalf.length;

    if (secondRate > firstRate + 0.1) return 1;
    if (secondRate < firstRate - 0.1) return -1;
    return 0;
  }

  /// Maps an attendance percentage to risk tiers.
  static AttendanceRiskLevel resolveRiskLevel(double percentage) {
    if (percentage >= 85.0) return AttendanceRiskLevel.low;
    if (percentage >= 75.0) return AttendanceRiskLevel.moderate;
    if (percentage >= 65.0) return AttendanceRiskLevel.high;
    return AttendanceRiskLevel.critical;
  }
}
