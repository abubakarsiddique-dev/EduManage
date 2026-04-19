import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/parent_feedback_model.dart';

void main() {
  group('ParentFeedbackModel Tests', () {
    test('status getters evaluate correctly', () {
      const pending = ParentFeedbackModel(
        id: 'f1',
        parentId: 'p1',
        parentName: 'Parent 1',
        studentId: 's1',
        subject: 'Transport Inquiry',
        message: 'Query regarding bus route 4.',
        status: FeedbackStatus.pending,
      );
      expect(pending.isPending, isTrue);
      expect(pending.isResolved, isFalse);

      const resolved = ParentFeedbackModel(
        id: 'f2',
        parentId: 'p2',
        parentName: 'Parent 2',
        studentId: 's2',
        subject: 'Fee adjustment',
        message: 'Paid on May 1st.',
        status: FeedbackStatus.resolved,
      );
      expect(resolved.isResolved, isTrue);
    });

    test('serialization roundtrip parses correctly', () {
      final map = {
        'parentId': 'p10',
        'parentName': 'Ali Khan',
        'studentId': 's20',
        'studentName': 'Zaid Khan',
        'subject': 'Exam Schedule',
        'message': 'When are midterm dates released?',
        'status': 'reviewed',
      };
      final model = ParentFeedbackModel.fromMap('f10', map);
      expect(model.id, 'f10');
      expect(model.status, FeedbackStatus.reviewed);
      expect(model.subject, 'Exam Schedule');
    });
  });
}
