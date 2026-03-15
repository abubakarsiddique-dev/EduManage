import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/school_event_model.dart';

void main() {
  group('SchoolEventModel Tests', () {
    test('isUpcoming and isHappeningNow evaluate correctly', () {
      final now = DateTime(2026, 3, 15, 12, 0);
      final futureEvent = SchoolEventModel(
        id: 'e1',
        title: 'Science Fair 2026',
        description: 'Exhibition of STEM models',
        venue: 'Auditorium',
        startDate: DateTime(2026, 3, 20, 9, 0),
        endDate: DateTime(2026, 3, 20, 16, 0),
      );

      expect(futureEvent.isUpcoming(now), isTrue);
      expect(futureEvent.isHappeningNow(now), isFalse);

      final currentEvent = SchoolEventModel(
        id: 'e2',
        title: 'Morning Assembly',
        description: 'Awards announcement',
        venue: 'Main Ground',
        startDate: DateTime(2026, 3, 15, 11, 0),
        endDate: DateTime(2026, 3, 15, 13, 0),
      );

      expect(currentEvent.isHappeningNow(now), isTrue);
    });

    test('serialization roundtrip preserves audience and status', () {
      final map = {
        'title': 'PTM Q1',
        'description': 'Quarterly Parent Teacher Meeting',
        'venue': 'Classrooms',
        'startDate': DateTime(2026, 3, 28, 9, 0).toIso8601String(),
        'endDate': DateTime(2026, 3, 28, 14, 0).toIso8601String(),
        'audience': 'parents_only',
        'isMandatory': true,
      };

      final model = SchoolEventModel.fromMap('e10', map);
      expect(model.audience, EventAudience.parentsOnly);
      expect(model.isMandatory, isTrue);
    });
  });
}
