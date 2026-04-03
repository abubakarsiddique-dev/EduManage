import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/time_slot_helper.dart';

void main() {
  group('TimeSlotHelper Tests', () {
    test('to12HourFormat converts military time to civilian AM/PM format', () {
      expect(TimeSlotHelper.to12HourFormat('08:15'), '08:15 AM');
      expect(TimeSlotHelper.to12HourFormat('14:45'), '02:45 PM');
      expect(TimeSlotHelper.to12HourFormat('00:00'), '12:00 AM');
      expect(TimeSlotHelper.to12HourFormat('12:00'), '12:00 PM');
    });

    test('hasOverlap detects schedule clashes', () {
      // 09:00 - 10:00 and 09:30 - 10:30 overlap
      expect(TimeSlotHelper.hasOverlap('09:00', '10:00', '09:30', '10:30'), isTrue);
      // 09:00 - 10:00 and 10:00 - 11:00 do not overlap (boundary adjacent)
      expect(TimeSlotHelper.hasOverlap('09:00', '10:00', '10:00', '11:00'), isFalse);
    });
  });
}
