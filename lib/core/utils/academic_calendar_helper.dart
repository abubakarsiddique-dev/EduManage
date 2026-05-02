/// Utilities for calculating academic terms, session duration, and calendar milestones.
class AcademicCalendarHelper {
  AcademicCalendarHelper._();

  /// Calculates the number of days remaining until [targetDate] from [fromDate].
  static int daysRemaining(DateTime targetDate, [DateTime? fromDate]) {
    final now = fromDate ?? DateTime.now();
    final difference = targetDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Determines whether the given date falls within the term range [start] and [end].
  static bool isDateInTerm(DateTime date, DateTime start, DateTime end) {
    return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
        (date.isBefore(end) || date.isAtSameMomentAs(end));
  }

  /// Calculates the percentage completion of an academic term (0.0 to 100.0).
  static double calculateTermProgress(DateTime start, DateTime end, [DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 100.0;

    final totalDuration = end.difference(start).inSeconds;
    if (totalDuration <= 0) return 100.0;

    final elapsed = now.difference(start).inSeconds;
    final progress = (elapsed / totalDuration) * 100.0;
    return double.parse(progress.clamp(0.0, 100.0).toStringAsFixed(1));
  }
}
