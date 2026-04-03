/// Helper for comparing time slots, checking timetable conflicts, and formatting 12h/24h time.
class TimeSlotHelper {
  TimeSlotHelper._();

  /// Converts '14:30' into 12-hour format with AM/PM ('02:30 PM').
  static String to12HourFormat(String time24) {
    try {
      final parts = time24.split(':').map(int.parse).toList();
      final hour = parts[0];
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final minuteStr = minute.toString().padLeft(2, '0');
      final hourStr = hour12.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr $period';
    } catch (_) {
      return time24;
    }
  }

  /// Checks if two time intervals [start1, end1] and [start2, end2] overlap.
  static bool hasOverlap(String start1, String end1, String start2, String end2) {
    try {
      final s1 = _toMinutes(start1);
      final e1 = _toMinutes(end1);
      final s2 = _toMinutes(start2);
      final e2 = _toMinutes(end2);
      return s1 < e2 && s2 < e1;
    } catch (_) {
      return false;
    }
  }

  static int _toMinutes(String time) {
    final parts = time.split(':').map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }
}
