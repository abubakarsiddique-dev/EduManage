import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('role check helpers evaluate correctly', () {
      const admin = UserModel(
        uid: 'u1',
        name: 'Admin User',
        email: 'admin@school.com',
        role: 'admin',
        approved: true,
      );
      expect(admin.isAdmin, isTrue);
      expect(admin.isTeacher, isFalse);
      expect(admin.isStudent, isFalse);

      const teacher = UserModel(
        uid: 'u2',
        name: 'Teacher User',
        email: 'teacher@school.com',
        role: 'teacher',
        approved: true,
      );
      expect(teacher.isTeacher, isTrue);

      const student = UserModel(
        uid: 'u3',
        name: 'Student User',
        email: 'student@school.com',
        role: 'student',
        approved: false,
      );
      expect(student.isStudent, isTrue);
    });

    test('equality and hashCode identify matching instances', () {
      const u1 = UserModel(
        uid: 'u1',
        name: 'User One',
        email: 'u1@school.com',
        role: 'admin',
        approved: true,
      );
      const u2 = UserModel(
        uid: 'u1',
        name: 'User One',
        email: 'u1@school.com',
        role: 'admin',
        approved: true,
      );
      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
    });
  });
}
