/// Defines predefined academic terms, exam windows, and holidays for the academic year.
class SchoolTermItem {
  final String termId;
  final String termName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime midtermExamDate;
  final DateTime finalExamDate;

  const SchoolTermItem({
    required this.termId,
    required this.termName,
    required this.startDate,
    required this.endDate,
    required this.midtermExamDate,
    required this.finalExamDate,
  });

  bool containsDate(DateTime date) =>
      (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
      (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
}

/// Academic calendar configuration and active term resolver.
class SchoolTermsConfig {
  SchoolTermsConfig._();

  static final List<SchoolTermItem> academicYear2026 = [
    SchoolTermItem(
      termId: 'spring_2026',
      termName: 'Spring Semester 2026',
      startDate: DateTime(2026, 1, 15),
      endDate: DateTime(2026, 5, 30),
      midtermExamDate: DateTime(2026, 3, 20),
      finalExamDate: DateTime(2026, 5, 20),
    ),
    SchoolTermItem(
      termId: 'summer_2026',
      termName: 'Summer Term 2026',
      startDate: DateTime(2026, 6, 15),
      endDate: DateTime(2026, 8, 15),
      midtermExamDate: DateTime(2026, 7, 10),
      finalExamDate: DateTime(2026, 8, 10),
    ),
    SchoolTermItem(
      termId: 'fall_2026',
      termName: 'Fall Semester 2026',
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 12, 23),
      midtermExamDate: DateTime(2026, 10, 25),
      finalExamDate: DateTime(2026, 12, 15),
    ),
  ];

  /// Finds the active term for a given date.
  static SchoolTermItem? getActiveTerm(DateTime date) {
    for (final term in academicYear2026) {
      if (term.containsDate(date)) return term;
    }
    return null;
  }
}
