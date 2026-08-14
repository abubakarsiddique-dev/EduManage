import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/hostel_room_model.dart';

void main() {
  group('HostelRoomModel Tests', () {
    test('occupancy predicates compute vacant beds accurately', () {
      const room = HostelRoomModel(
        id: 'hr1',
        roomNumber: '302',
        hostelBlock: 'Jinnah Hall',
        capacity: 3,
        occupiedBeds: 2,
        monthlyRent: 12000,
      );

      expect(room.isFull, isFalse);
      expect(room.vacantBeds, 1);
    });

    test('isFull is true when room capacity reached', () {
      const fullRoom = HostelRoomModel(
        id: 'hr2',
        roomNumber: '101',
        hostelBlock: 'Iqbal Hall',
        capacity: 2,
        occupiedBeds: 2,
        monthlyRent: 15000,
      );

      expect(fullRoom.isFull, isTrue);
      expect(fullRoom.vacantBeds, 0);
    });
  });
}
