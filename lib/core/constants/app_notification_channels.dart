/// Notification channel definitions, priorities, and descriptions.
class AppNotificationChannels {
  AppNotificationChannels._();

  static const String academic = 'academic_alerts';
  static const String attendance = 'attendance_updates';
  static const String fees = 'fee_reminders';
  static const String notices = 'school_notices';
  static const String system = 'system_announcements';

  static const Map<String, String> channelNames = {
    academic: 'Academic Alerts',
    attendance: 'Attendance Updates',
    fees: 'Fee Reminders',
    notices: 'School Notices',
    system: 'System Announcements',
  };

  static const Map<String, String> channelDescriptions = {
    academic: 'Notifications regarding assignments, exam timetables, and report cards.',
    attendance: 'Real-time alerts when student attendance is logged or absence reported.',
    fees: 'Billing reminders, fee voucher generation, and payment receipts.',
    notices: 'General circulars, administrative alerts, and holiday notifications.',
    system: 'Important app updates, maintenance schedules, and security advisories.',
  };

  /// Retrieves the channel display name or fallback.
  static String getName(String channelId, [String fallback = 'General Notification']) {
    return channelNames[channelId] ?? fallback;
  }
}
