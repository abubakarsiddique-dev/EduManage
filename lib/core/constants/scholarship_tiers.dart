/// Institutional scholarship discount percentages, eligibility guidelines, and quotas.
class ScholarshipTiers {
  ScholarshipTiers._();

  static const double fullBright = 100.0;
  static const double presidentMerit = 75.0;
  static const double deanHonor = 50.0;
  static const double sportsExcellence = 35.0;
  static const double siblingDiscount = 25.0;
  static const double needBasedAid = 40.0;

  /// Returns recommended scholarship discount based on GPA.
  static double getRecommendedDiscountForGpa(double gpa) {
    if (gpa >= 3.95) return fullBright;
    if (gpa >= 3.85) return presidentMerit;
    if (gpa >= 3.70) return deanHonor;
    return 0.0;
  }
}
