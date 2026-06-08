import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/facility_booking_model.dart';

void main() {
  group('FacilityBookingModel Tests', () {
    test('status predicates evaluate correctly', () {
      final booking = FacilityBookingModel(
        id: 'bk1',
        facilityName: 'Main Auditorium',
        requestedBy: 'Sir Tariq',
        userRole: 'teacher',
        bookingDate: DateTime(2026, 6, 8),
        startTime: '10:00',
        endTime: '12:00',
        purpose: 'Debate Competition Rehearsal',
        status: BookingStatus.approved,
      );

      expect(booking.isApproved, isTrue);
      expect(booking.isPending, isFalse);
    });

    test('serialization roundtrip preserves facility purpose and time', () {
      final map = {
        'facilityName': 'Chemistry Lab B',
        'requestedBy': 'Student Council',
        'userRole': 'student_council',
        'bookingDate': DateTime(2026, 6, 12).toIso8601String(),
        'startTime': '14:00',
        'endTime': '16:00',
        'purpose': 'Science Olympiad Trial',
        'status': 'pending',
      };

      final model = FacilityBookingModel.fromMap('bk10', map);
      expect(model.facilityName, 'Chemistry Lab B');
      expect(model.isPending, isTrue);
      expect(model.toMap()['userRole'], 'student_council');
    });
  });
}
