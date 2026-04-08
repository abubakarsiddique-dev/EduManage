import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/extracurricular_club_model.dart';

void main() {
  group('ExtracurricularClubModel Tests', () {
    test('serialization roundtrip preserves club details', () {
      final map = {
        'clubName': 'Robotics & AI Club',
        'category': 'Science & Tech',
        'patronTeacherId': 't5',
        'patronTeacherName': 'Engr. Bilal',
        'memberCount': 28,
        'meetingSchedule': 'Thursday 4:00 PM',
        'isRecruiting': true,
      };

      final model = ExtracurricularClubModel.fromMap('club1', map);
      expect(model.clubName, 'Robotics & AI Club');
      expect(model.memberCount, 28);
      expect(model.isRecruiting, isTrue);

      final exported = model.toMap();
      expect(exported['patronTeacherName'], 'Engr. Bilal');
    });
  });
}
