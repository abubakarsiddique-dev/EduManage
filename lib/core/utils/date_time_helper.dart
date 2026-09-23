import 'package:intl/intl.dart';

/// Centralized date and time formatting and computation utility suite.
class DateTimeHelper {
  DateTimeHelper._();

  static final DateFormat _isoDateFormatter = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFormatter = DateFormat('MMM d, yyyy');
  static final DateFormat _displayTimeFormatter = DateFormat('h:mm a');
  static final DateFormat _fullDateTimeFormatter = DateFormat(
    'MMM d, yyyy • h:mm a',
  );
  static final DateFormat _monthYearFormatter = DateFormat('MMMM yyyy');

  /// Formats date to 'yyyy-MM-dd' (standard API format).
  static String formatIsoDate(DateTime? date) {
    if (date == null) return '';
    return _isoDateFormatter.format(date);
  }

  /// Formats date to 'MMM d, yyyy' (e.g. 'Oct 14, 2026').
  static String formatDisplayDate(DateTime? date) {
    if (date == null) return '';
    return _displayDateFormatter.format(date);
  }

  /// Formats time to 'h:mm a' (e.g. '10:30 AM').
  static String formatDisplayTime(DateTime? date) {
    if (date == null) return '';
    return _displayTimeFormatter.format(date);
  }

  /// Formats combined date and time (e.g. 'Oct 14, 2026 • 10:30 AM').
  static String formatFullDateTime(DateTime? date) {
    if (date == null) return '';
    return _fullDateTimeFormatter.format(date);
  }

  /// Formats month and year (e.g. 'October 2026').
  static String formatMonthYear(DateTime? date) {
    if (date == null) return '';
    return _monthYearFormatter.format(date);
  }

  /// Generates a human-friendly relative time string (e.g., 'Just now', '5m ago', '2h ago', 'Yesterday', etc.)
  static String timeAgo(DateTime? date, {DateTime? clock}) {
    if (date == null) return '';
    final now = clock ?? DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return 'In the future';
    }

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '${mins}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return formatDisplayDate(date);
    }
  }

  /// Checks if two dates fall on the exact same calendar day.
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if a given date is today.
  static bool isToday(DateTime? date, {DateTime? clock}) {
    if (date == null) return false;
    final now = clock ?? DateTime.now();
    return isSameDay(date, now);
  }

  /// Parses date string safely without throwing exceptions.
  static DateTime? safeParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return DateTime.parse(raw.trim());
    } catch (_) {
      return null;
    }
  }

  /// Calculates remaining days until deadline, returning negative if overdue.
  static int daysUntil(DateTime? target, {DateTime? clock}) {
    if (target == null) return 0;
    final now = clock ?? DateTime.now();
    final targetDate = DateTime(target.year, target.month, target.day);
    final today = DateTime(now.year, now.month, now.day);
    return targetDate.difference(today).inDays;
  }

  /// Checks whether a given [target] date falls inclusively between [start] and [end].
  static bool isDateInRange(DateTime? target, DateTime? start, DateTime? end) {
    if (target == null || start == null || end == null) return false;
    final t = DateTime(target.year, target.month, target.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !t.isBefore(s) && !t.isAfter(e);
  }

  /// Formats date to academic year label (e.g., '2026-2027' when term starts in August/September).
  static String formatAcademicYear(DateTime? date, {int startMonth = 8}) {
    if (date == null) return '';
    final year = date.year;
    if (date.month >= startMonth) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }

  /// Returns the calendar quarter string for the date (e.g., 'Q1', 'Q2', 'Q3', 'Q4').
  static String getQuarter(DateTime? date) {
    if (date == null) return '';
    final q = ((date.month - 1) ~/ 3) + 1;
    return 'Q$q';
  }

  /// Computes the start of the week (Monday at 00:00:00) for a given date.
  static DateTime? startOfWeek(DateTime? date) {
    if (date == null) return null;
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Computes the end of the week (Sunday at 23:59:59) for a given date.
  static DateTime? endOfWeek(DateTime? date) {
    if (date == null) return null;
    final start = startOfWeek(date)!;
    return DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
  }
}

