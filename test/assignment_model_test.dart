import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/assignment_model.dart';

void main() {
  group('AssignmentModel Tests', () {
    test('isDueSoon detects approaching deadlines', () {
      final assignment = AssignmentModel(
        id: 'a1',
        title: 'Physics Lab',
        subject: 'Physics',
        className: '10-A',
        teacherId: 't1',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(assignment.isDueSoon, isTrue);
      expect(assignment.isOverdue, isFalse);
    });

    test('equality and hashCode match identical properties', () {
      final a1 = AssignmentModel(
        id: 'a1',
        title: 'Math Quiz',
        subject: 'Math',
        className: '10-B',
        teacherId: 't1',
      );
      final a2 = AssignmentModel(
        id: 'a1',
        title: 'Math Quiz',
        subject: 'Math',
        className: '10-B',
        teacherId: 't1',
      );
      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
    });
  });
}
