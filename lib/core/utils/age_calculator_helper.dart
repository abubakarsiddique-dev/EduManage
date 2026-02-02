/// Helper for computing exact age, eligibility thresholds, and session cutoffs for student admissions.
class AgeCalculatorHelper {
  AgeCalculatorHelper._();

  /// Calculates exact chronological age in completed years.
  static int calculateYears(DateTime birthDate, [DateTime? asOfDate]) {
    final now = asOfDate ?? DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  /// Calculates human-readable age breakdown (e.g. "15 years, 4 months").
  static String formatAge(DateTime birthDate, [DateTime? asOfDate]) {
    final now = asOfDate ?? DateTime.now();
    var years = now.year - birthDate.year;
    var months = now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    return '$years years, $months months';
  }

  /// Verifies if a student satisfies the minimum enrollment age requirement.
  static bool isEligibleForGrade(DateTime birthDate, int minAge, [DateTime? sessionStart]) {
    final age = calculateYears(birthDate, sessionStart);
    return age >= minAge;
  }
}
