import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/syllabus_topic_model.dart';

void main() {
  group('SyllabusTopicModel Tests', () {
    test('progressPercentage calculates ratio correctly', () {
      const topic = SyllabusTopicModel(
        id: 's1',
        subject: 'Biology',
        className: '9-A',
        chapterNumber: '3',
        topicTitle: 'Cell Structure and Functions',
        totalLessons: 8,
        completedLessons: 6,
      );

      expect(topic.progressPercentage, 75.0);
    });

    test('serialization roundtrip preserves chapter details', () {
      final map = {
        'subject': 'Mathematics',
        'className': '10-B',
        'chapterNumber': '5',
        'topicTitle': 'Quadratic Equations',
        'totalLessons': 10,
        'completedLessons': 10,
        'isCompleted': true,
      };

      final model = SyllabusTopicModel.fromMap('s5', map);
      expect(model.isCompleted, isTrue);
      expect(model.progressPercentage, 100.0);
      expect(model.toMap()['topicTitle'], 'Quadratic Equations');
    });
  });
}
