import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/bell_schedule_model.dart';

void main() {
  group('BellScheduleModel Tests', () {
    test('durationMinutes calculates elapsed minutes accurately', () {
      const period = BellScheduleModel(
        id: 'p1',
        periodName: 'Mathematics',
        periodNumber: 1,
        startTime: '08:00',
        endTime: '08:45',
      );
      expect(period.durationMinutes, 45);

      const lunch = BellScheduleModel(
        id: 'p4',
        periodName: 'Lunch Break',
        periodNumber: 4,
        startTime: '12:00',
        endTime: '12:35',
        isRecess: true,
      );
      expect(lunch.durationMinutes, 35);
      expect(lunch.isRecess, isTrue);
    });

    test('serialization roundtrip preserves values', () {
      final map = {
        'periodName': 'Chemistry Lab',
        'periodNumber': 3,
        'startTime': '10:00',
        'endTime': '11:30',
        'isRecess': false,
      };

      final model = BellScheduleModel.fromMap('p3', map);
      expect(model.durationMinutes, 90);
      expect(model.toMap()['isRecess'], isFalse);
    });
  });
}
