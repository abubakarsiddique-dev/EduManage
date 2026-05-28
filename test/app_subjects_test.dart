import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/constants/app_subjects.dart';

void main() {
  group('AppSubjects Constants Test Suite', () {
    test('allSubjects returns sorted unique subjects list', () {
      final all = AppSubjects.allSubjects;
      expect(all, isNotEmpty);
      expect(all.contains('Maths'), isTrue);
      expect(all.contains('English'), isTrue);
      expect(all.contains('Physics'), isTrue);
      expect(all.contains('Urdu'), isTrue);

      final sorted = List<String>.from(all)..sort();
      expect(all, equals(sorted));
    });

    test('subjectsForClassName returns correct early level and grade subjects', () {
      final nursery = AppSubjects.subjectsForClassName('Nursery - A');
      expect(nursery, equals(AppSubjects.earlyLevelSubjects));

      final kg = AppSubjects.subjectsForClassName('KG - Blue');
      expect(kg, equals(AppSubjects.earlyLevelSubjects));

      final grade10 = AppSubjects.subjectsForClassName('Grade 10 - A');
      expect(grade10, equals(AppSubjects.gradeLevelSubjects));

      final fallback = AppSubjects.subjectsForClassName(null);
      expect(fallback, equals(AppSubjects.gradeLevelSubjects));
    });

    test('subjectCategory accurately classifies subjects into faculties', () {
      expect(AppSubjects.subjectCategory('Physics'), 'Sciences');
      expect(AppSubjects.subjectCategory('Chemistry'), 'Sciences');
      expect(AppSubjects.subjectCategory('Biology'), 'Sciences');
      expect(AppSubjects.subjectCategory('Maths'), 'Mathematics');
      expect(AppSubjects.subjectCategory('English'), 'Languages');
      expect(AppSubjects.subjectCategory('Urdu'), 'Languages');
      expect(AppSubjects.subjectCategory('Computer Science'), 'Technology');
      expect(AppSubjects.subjectCategory('Islamiyat'), 'Humanities');
      expect(AppSubjects.subjectCategory('Pakistan Studies'), 'Humanities');
      expect(AppSubjects.subjectCategory('Unknown Subject'), 'General');
      expect(AppSubjects.subjectCategory(null), 'General');
    });

    test('isStemSubject identifies STEM vs non-STEM correctly', () {
      expect(AppSubjects.isStemSubject('Physics'), isTrue);
      expect(AppSubjects.isStemSubject('Maths'), isTrue);
      expect(AppSubjects.isStemSubject('Computer Science'), isTrue);
      expect(AppSubjects.isStemSubject('English'), isFalse);
      expect(AppSubjects.isStemSubject('Islamiyat'), isFalse);
    });

    test('AppQualifications contains standard academic qualifications', () {
      expect(AppQualifications.all, containsAll(['BS', 'MS', 'MPhil', 'PhD']));
    });
  });
}
