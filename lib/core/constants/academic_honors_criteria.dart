/// Threshold benchmarks and requirements for graduation honors and academic distinctions.
class AcademicHonorsCriteria {
  AcademicHonorsCriteria._();

  static const double summaCumLaudeMinGpa = 3.90;
  static const double magnaCumLaudeMinGpa = 3.75;
  static const double cumLaudeMinGpa = 3.50;
  static const double deansListMinGpa = 3.65;

  static const double minAttendancePercentage = 85.0;

  /// Determines honors distinction for a given GPA and attendance rate.
  static String? evaluateHonors(double gpa, double attendancePercentage) {
    if (attendancePercentage < minAttendancePercentage) return null;

    if (gpa >= summaCumLaudeMinGpa) {
      return 'Summa Cum Laude (Highest Honors)';
    } else if (gpa >= magnaCumLaudeMinGpa) {
      return 'Magna Cum Laude (High Honors)';
    } else if (gpa >= cumLaudeMinGpa) {
      return 'Cum Laude (Honors)';
    }
    return null;
  }

  /// Verifies Dean's List inclusion eligibility.
  static bool qualifiesForDeansList(double gpa, double attendancePercentage) {
    return gpa >= deansListMinGpa && attendancePercentage >= minAttendancePercentage;
  }
}
