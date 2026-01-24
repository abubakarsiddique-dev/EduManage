/// Centralized registry of static SVG, image, and illustration asset paths.
class AppAssetPaths {
  AppAssetPaths._();

  static const String baseIcons = 'assets/icons';
  static const String baseImages = 'assets/images';

  // Core Logo & Branding
  static const String logo = '$baseImages/logo.png';
  static const String appIcon = '$baseIcons/app_icon.svg';

  // Navigation Icons
  static const String dashboardIcon = '$baseIcons/dashboard.svg';
  static const String classesIcon = '$baseIcons/classes.svg';
  static const String studentsIcon = '$baseIcons/students.svg';
  static const String teachersIcon = '$baseIcons/teachers.svg';
  static const String attendanceIcon = '$baseIcons/attendance.svg';
  static const String feesIcon = '$baseIcons/fees.svg';
  static const String timetableIcon = '$baseIcons/timetable.svg';
  static const String assignmentsIcon = '$baseIcons/assignments.svg';
  static const String resultsIcon = '$baseIcons/results.svg';
  static const String noticesIcon = '$baseIcons/notices.svg';

  // Transport & Facilities
  static const String busIcon = '$baseIcons/bus.svg';
  static const String libraryIcon = '$baseIcons/library.svg';

  // Status & Placeholder Illustrations
  static const String emptyState = '$baseImages/empty_state.svg';
  static const String errorState = '$baseImages/error_state.svg';
  static const String offlineState = '$baseImages/offline_state.svg';

  /// Validates whether a given path is an SVG asset.
  static bool isSvg(String path) => path.toLowerCase().endsWith('.svg');

  /// Validates whether a given path is a PNG image.
  static bool isPng(String path) => path.toLowerCase().endsWith('.png');
}
