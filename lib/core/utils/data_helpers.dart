import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:school_management_system/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared data-transformation helpers.
///
/// Scope: every function here was copy-pasted verbatim (or near-verbatim)
/// in at least two places before this file existed:
///   - `_letterGrade` / `_gradeColor`: duplicated in
///     student_results_screen.dart, parent_result.dart, and inlined again
///     in grades_screen.dart's grade-saving logic.
///   - `todayKey` / date-key formatting: duplicated in attendence_repo.dart
///     (as `todayKey()`) and class_attendence.dart (as `_todayKey` getter).
///   - `dateLabel`: duplicated in student_notices_screen.dart's
///     `_formatDate` and notifications.dart's `_dateLabel`.
///
/// Existing call sites are NOT changed by adding this file — swapping
/// them over to call `DataHelpers.xxx` instead of their local private
/// copies is a separate, mechanical cleanup pass so it doesn't get
/// tangled with this file's introduction. New screens should call these
/// instead of writing a fifth copy.
class DataHelpers {
  DataHelpers._();

  // ── Grades ───────────────────────────────────────────────────────────
  static String letterGrade(double pct) {
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    if (pct >= 50) return 'C';
    if (pct >= 40) return 'D';
    return 'F';
  }

  static Color gradeColor(double pct) {
    if (pct >= 80) return AppColors.success;
    if (pct >= 60) return AppColors.primary;
    if (pct >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  // ── Dates ────────────────────────────────────────────────────────────

  /// Today's date as 'yyyy-MM-dd', matching the format already written by
  /// every existing attendance write path (attendence_repo.dart,
  /// class_attendence.dart). Keep using THIS format for any new
  /// attendance-related Firestore writes — switching formats would break
  /// the date range queries added in reports_screen.dart, which assume
  /// lexicographic string ordering of 'yyyy-MM-dd' values.
  static String todayKey() => dateKey(DateTime.now());

  static String dateKey(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  /// Short label like "Jun 16" — matches NoticeModel.dateLabel's format
  /// but usable for any DateTime, not just notice documents.
  static String shortDateLabel(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  /// "Today" / "Yesterday" / formatted date — matches the logic already
  /// duplicated in notifications.dart's `_dateLabel`.
  static String relativeDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  /// Safely converts a Firestore field that might be a Timestamp into a
  /// DateTime, returning null instead of throwing if the field is missing
  /// or the wrong type. Several screens currently do
  /// `(data['createdAt'] as Timestamp?)?.toDate()` inline — this is the
  /// same thing, just named, for readability in new code.
  static DateTime? timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  // ── Percentages ──────────────────────────────────────────────────────

  /// Safely computes a percentage, returning 0 instead of throwing/NaN
  /// when `total` is 0. Several screens duplicate the
  /// `total == 0 ? 0 : (marks / total) * 100` ternary inline.
  static double safePercentage(double obtained, double total) {
    if (total <= 0) return 0;
    return (obtained / total) * 100;
  }

  // ── Currency & String Formatting ──────────────────────────────────────

  /// Formats a numeric amount with standard thousand separators (e.g. 'Rs. 4,500').
  static String formatCurrency(
    num? amount, {
    String prefix = 'Rs. ',
    int decimalDigits = 0,
  }) {
    if (amount == null) return '${prefix}0';
    final formatter = NumberFormat.currency(
      symbol: prefix,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount).trim();
  }

  /// Truncates text exceeding [maxLength] and attaches an ellipsis '...'.
  static String truncateWithEllipsis(String? text, int maxLength) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    if (maxLength <= 3) return text.substring(0, maxLength);
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Converts a string into Title Case capitalized words.
  static String titleCase(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    return text.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  /// Formats byte count into a human-readable file size string (B, KB, MB, GB).
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Clamps a numeric value safely between [min] and [max].
  static double clampNumeric(num value, num min, num max) {
    if (value < min) return min.toDouble();
    if (value > max) return max.toDouble();
    return value.toDouble();
  }
}


