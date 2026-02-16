import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/staff_attendance_model.dart';

void main() {
  group('StaffAttendanceModel Tests', () {
    test('totalHoursWorked computes correct duration', () {
      final record = StaffAttendanceModel(
        id: 'att1',
        staffId: 'teacher10',
        staffName: 'Dr. Munir',
        role: 'teacher',
        date: DateTime(2026, 2, 16),
        checkInTime: '08:00',
        checkOutTime: '15:30',
        status: StaffAttendanceStatus.present,
      );

      expect(record.isPunctual, isTrue);
      expect(record.totalHoursWorked, 7.5);
    });

    test('late status evaluates isPunctual as false', () {
      final record = StaffAttendanceModel(
        id: 'att2',
        staffId: 'teacher12',
        staffName: 'Sir Rashid',
        role: 'teacher',
        date: DateTime(2026, 2, 16),
        checkInTime: '08:45',
        status: StaffAttendanceStatus.lateArrival,
      );

      expect(record.isPunctual, isFalse);
    });
  });
}
