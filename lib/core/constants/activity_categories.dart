/// Taxonomy of recognized school sports, academic clubs, and extracurricular societies.
class ActivityCategories {
  ActivityCategories._();

  static const String sports = 'Sports & Athletics';
  static const String scienceAndTech = 'Science & Technology';
  static const String artsAndCulture = 'Arts & Culture';
  static const String literaryAndDebate = 'Literary & Debating';
  static const String communityService = 'Community Service';
  static const String leadership = 'Student Council & Leadership';

  static const List<String> all = [
    sports,
    scienceAndTech,
    artsAndCulture,
    literaryAndDebate,
    communityService,
    leadership,
  ];

  static bool isValidCategory(String category) => all.contains(category.trim());
}
