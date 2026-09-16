import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/utils/attendance_forecasting_engine.dart';

void main() {
  group('AttendanceForecastingEngine Test Suite', () {
    test('forecastAttendance computes baseline percentages accurately', () {
      // 80 attended out of 100 conducted, 20 classes remaining
      final forecast = AttendanceForecastingEngine.forecastAttendance(
        attended: 80,
        totalConducted: 100,
        remainingClasses: 20,
        mandatoryThreshold: 75.0,
      );

      expect(forecast.currentPercentage, 80.0);
      expect(forecast.isInDeficit, isFalse);
      expect(forecast.riskLevel, AttendanceRiskLevel.moderate);

      // Best case: 80 + 20 = 100 / 120 = 83.33%
      expect(forecast.projectedBestCasePercentage, closeTo(83.33, 0.05));
      // Worst case: 80 / 120 = 66.67%
      expect(forecast.projectedWorstCasePercentage, closeTo(66.67, 0.05));
    });

    test('forecastAttendance accurately computes max allowable future absences', () {
      // Total term = 100 conducted + 20 remaining = 120 classes
      // 75% of 120 = 90 classes needed
      // Currently attended: 85
      // Max missable = (85 + 20) - 90 = 105 - 90 = 15 classes
      final forecast = AttendanceForecastingEngine.forecastAttendance(
        attended: 85,
        totalConducted: 100,
        remainingClasses: 20,
        mandatoryThreshold: 75.0,
      );

      expect(forecast.maxAllowableFutureAbsences, 15);
    });

    test('forecastAttendance detects deficit and calculates recovery streak', () {
      // 60 attended out of 100 conducted (60%) -> In deficit vs 75%
      // Remaining classes: 80
      // Recovery formula: n >= (0.75 * 100 - 60) / (1 - 0.75) = (75 - 60) / 0.25 = 15 / 0.25 = 60 classes
      final forecast = AttendanceForecastingEngine.forecastAttendance(
        attended: 60,
        totalConducted: 100,
        remainingClasses: 80,
        mandatoryThreshold: 75.0,
      );

      expect(forecast.isInDeficit, isTrue);
      expect(forecast.recoveryClassesNeeded, 60);
      expect(forecast.isRecoveryPossible, isTrue);
      expect(forecast.maxAllowableFutureAbsences, 5);
    });

    test('forecastAttendance flags mathematically impossible recovery', () {
      // 50 attended out of 100 conducted (50%) -> Needs 100 recovery classes
      // But only 10 classes remain in term!
      final forecast = AttendanceForecastingEngine.forecastAttendance(
        attended: 50,
        totalConducted: 100,
        remainingClasses: 10,
        mandatoryThreshold: 75.0,
      );

      expect(forecast.isInDeficit, isTrue);
      expect(forecast.recoveryClassesNeeded, greaterThan(10));
      expect(forecast.isRecoveryPossible, isFalse);
    });

    test('simulateLeaveImpact assesses drop and flags threshold breach', () {
      // 76 attended out of 100 conducted (76%)
      // Requests 5 days leave -> drops to 76 / 105 = 72.38% (breaches 75%)
      const summary = AttendanceRecordSummary(
        totalClassesConducted: 100,
        classesAttended: 76,
      );

      final assessment = AttendanceForecastingEngine.simulateLeaveImpact(
        summary: summary,
        requestedLeaveDays: 5,
        remainingClasses: 20,
        mandatoryThreshold: 75.0,
      );

      expect(assessment.breachesThreshold, isTrue);
      expect(assessment.projectedPercentageAfterLeave, closeTo(72.38, 0.05));
      expect(assessment.percentageDrop, closeTo(3.62, 0.05));
      expect(assessment.recommendation, contains('CAUTION'));
    });

    test('simulateLeaveImpact handles safe leave buffer approval', () {
      // 95 attended out of 100 conducted (95%)
      // Requests 2 days leave -> drops to 95 / 102 = 93.13% (well above 75%)
      const summary = AttendanceRecordSummary(
        totalClassesConducted: 100,
        classesAttended: 95,
      );

      final assessment = AttendanceForecastingEngine.simulateLeaveImpact(
        summary: summary,
        requestedLeaveDays: 2,
        remainingClasses: 20,
        mandatoryThreshold: 75.0,
      );

      expect(assessment.breachesThreshold, isFalse);
      expect(assessment.recommendation, contains('APPROVED'));
    });

    test('simulateLeaveImpact handles zero days gracefully', () {
      const summary = AttendanceRecordSummary(
        totalClassesConducted: 50,
        classesAttended: 45,
      );

      final assessment = AttendanceForecastingEngine.simulateLeaveImpact(
        summary: summary,
        requestedLeaveDays: 0,
        remainingClasses: 20,
      );

      expect(assessment.breachesThreshold, isFalse);
      expect(assessment.percentageDrop, 0.0);
    });

    test('calculateTrajectoryTrend recognizes improving and declining streaks', () {
      // Improving: missed first 3, attended last 4
      final improving = [false, false, false, true, true, true, true];
      expect(AttendanceForecastingEngine.calculateTrajectoryTrend(improving), 1);

      // Declining: attended first 4, missed last 3
      final declining = [true, true, true, true, false, false, false];
      expect(AttendanceForecastingEngine.calculateTrajectoryTrend(declining), -1);

      // Stable: consistent attendance
      final stable = [true, true, true, true, true, true];
      expect(AttendanceForecastingEngine.calculateTrajectoryTrend(stable), 0);
    });

    test('resolveRiskLevel classifies all 4 tiers properly', () {
      expect(AttendanceForecastingEngine.resolveRiskLevel(92.0), AttendanceRiskLevel.low);
      expect(AttendanceForecastingEngine.resolveRiskLevel(79.0), AttendanceRiskLevel.moderate);
      expect(AttendanceForecastingEngine.resolveRiskLevel(68.0), AttendanceRiskLevel.high);
      expect(AttendanceForecastingEngine.resolveRiskLevel(55.0), AttendanceRiskLevel.critical);
    });
  });
}
