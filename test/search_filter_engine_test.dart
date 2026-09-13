import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/utils/search_filter_engine.dart';

class TestStudent {
  final String id;
  final String name;
  final String gradeLevel;
  final double gpa;
  final DateTime enrolledAt;
  final String? parentEmail;

  TestStudent({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.gpa,
    required this.enrolledAt,
    this.parentEmail,
  });
}

void main() {
  group('SearchFilterEngine Test Suite', () {
    const engine = SearchFilterEngine<TestStudent>();

    final sampleStudents = [
      TestStudent(
        id: 's1',
        name: 'Alice Johnson',
        gradeLevel: 'Grade 10',
        gpa: 3.85,
        enrolledAt: DateTime.utc(2024, 9, 1),
        parentEmail: 'parent.alice@email.com',
      ),
      TestStudent(
        id: 's2',
        name: 'Bob Smith',
        gradeLevel: 'Grade 11',
        gpa: 3.20,
        enrolledAt: DateTime.utc(2023, 9, 1),
        parentEmail: null,
      ),
      TestStudent(
        id: 's3',
        name: 'Charlie Brown',
        gradeLevel: 'Grade 10',
        gpa: 2.75,
        enrolledAt: DateTime.utc(2024, 9, 5),
        parentEmail: 'parent.charlie@email.com',
      ),
      TestStudent(
        id: 's4',
        name: 'Diana Prince',
        gradeLevel: 'Grade 12',
        gpa: 3.95,
        enrolledAt: DateTime.utc(2022, 9, 1),
        parentEmail: 'diana.mom@email.com',
      ),
      TestStudent(
        id: 's5',
        name: 'Evan Johnson',
        gradeLevel: 'Grade 11',
        gpa: 3.85,
        enrolledAt: DateTime.utc(2023, 9, 15),
        parentEmail: 'evan.dad@email.com',
      ),
    ];

    test('FilterPredicate.equals filters by exact match', () {
      final predicate = FilterPredicate.equals(
        (TestStudent s) => s.gradeLevel,
        'Grade 10',
      );
      final filtered = engine.filter(sampleStudents, [predicate]);

      expect(filtered.length, equals(2));
      expect(filtered.map((s) => s.name), containsAll(['Alice Johnson', 'Charlie Brown']));
    });

    test('FilterPredicate.inList matches set of allowed categories', () {
      final predicate = FilterPredicate.inList(
        (TestStudent s) => s.gradeLevel,
        ['Grade 11', 'Grade 12'],
      );
      final filtered = engine.filter(sampleStudents, [predicate]);

      expect(filtered.length, equals(3));
      expect(filtered.map((s) => s.id), containsAll(['s2', 's4', 's5']));
    });

    test('FilterPredicate.range checks numeric bounds', () {
      final honorsPredicate = FilterPredicate.range(
        (TestStudent s) => s.gpa,
        min: 3.5,
        max: 4.0,
      );
      final filtered = engine.filter(sampleStudents, [honorsPredicate]);

      expect(filtered.length, equals(3));
      expect(filtered.map((s) => s.id), containsAll(['s1', 's4', 's5']));
    });

    test('FilterPredicate.dateBetween checks datetime window', () {
      final datePredicate = FilterPredicate.dateBetween(
        (TestStudent s) => s.enrolledAt,
        start: DateTime.utc(2024, 1, 1),
        end: DateTime.utc(2024, 12, 31),
      );
      final filtered = engine.filter(sampleStudents, [datePredicate]);

      expect(filtered.length, equals(2));
      expect(filtered.map((s) => s.id), containsAll(['s1', 's3']));
    });

    test('search tokenizes text and matches case-insensitively', () {
      final searchResults = engine.search(
        sampleStudents,
        'johnson',
        [(s) => s.name, (s) => s.id],
      );

      expect(searchResults.length, equals(2));
      expect(searchResults.map((s) => s.name), containsAll(['Alice Johnson', 'Evan Johnson']));

      final multiToken = engine.search(
        sampleStudents,
        'alice 10',
        [(s) => s.name, (s) => s.gradeLevel],
        matchAllTokens: true,
      );
      expect(multiToken.length, equals(1));
      expect(multiToken.first.name, equals('Alice Johnson'));
    });

    test('sort orders items with null handling and ties resolution', () {
      final sortedByGpa = engine.sort(sampleStudents, [
        SortCriterion<TestStudent>(
          selector: (s) => s.gpa,
          order: SortOrder.descending,
        ),
        SortCriterion<TestStudent>(
          selector: (s) => s.name,
          order: SortOrder.ascending,
        ),
      ]);

      expect(sortedByGpa.first.name, equals('Diana Prince')); // 3.95
      expect(sortedByGpa[1].name, equals('Alice Johnson')); // 3.85 (A before E)
      expect(sortedByGpa[2].name, equals('Evan Johnson')); // 3.85
      expect(sortedByGpa.last.name, equals('Charlie Brown')); // 2.75
    });

    test('paginate computes page slices and bounds navigation', () {
      final page1 = engine.paginate(sampleStudents, page: 1, pageSize: 2);
      expect(page1.items.length, equals(2));
      expect(page1.totalCount, equals(5));
      expect(page1.totalPages, equals(3));
      expect(page1.hasNextPage, isTrue);
      expect(page1.hasPreviousPage, isFalse);

      final page3 = engine.paginate(sampleStudents, page: 3, pageSize: 2);
      expect(page3.items.length, equals(1));
      expect(page3.hasNextPage, isFalse);
      expect(page3.hasPreviousPage, isTrue);

      final pageOutOfBounds = engine.paginate(sampleStudents, page: 99, pageSize: 2);
      expect(pageOutOfBounds.items.isEmpty, isTrue);
    });

    test('computeFacetCounts calculates category frequencies', () {
      final counts = engine.computeFacetCounts(
        sampleStudents,
        (s) => s.gradeLevel,
      );

      expect(counts['Grade 10'], equals(2));
      expect(counts['Grade 11'], equals(2));
      expect(counts['Grade 12'], equals(1));
    });

    test('execute applies full search, filter, sort, and pagination pipeline', () {
      final result = engine.execute(
        items: sampleStudents,
        query: 'johnson',
        searchExtractors: [(s) => s.name],
        predicates: [
          FilterPredicate.range((s) => s.gpa, min: 3.5),
        ],
        sortCriteria: [
          SortCriterion(
            selector: (s) => s.enrolledAt,
            order: SortOrder.descending,
          ),
        ],
        page: 1,
        pageSize: 10,
      );

      expect(result.totalCount, equals(2));
      expect(result.items.first.name, equals('Alice Johnson')); // enrolled 2024 vs 2023
    });
  });
}
