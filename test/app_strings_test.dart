import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/constants/app_strings.dart';

void main() {
  group('AppStrings Constants Test Suite', () {
    test('roleLabel maps user roles accurately', () {
      expect(AppStrings.roleLabel('admin'), AppStrings.roleAdmin);
      expect(AppStrings.roleLabel('teacher'), AppStrings.roleTeacher);
      expect(AppStrings.roleLabel('parent'), AppStrings.roleParent);
      expect(AppStrings.roleLabel('student'), AppStrings.roleStudent);
      expect(AppStrings.roleLabel('unknown'), AppStrings.roleStudent);
      expect(AppStrings.roleLabel(null), AppStrings.roleStudent);
    });

    test('standard actions and feedback strings are correctly defined', () {
      expect(AppStrings.appName, 'EduManage');
      expect(AppStrings.save, 'Save');
      expect(AppStrings.cancel, 'Cancel');
      expect(AppStrings.delete, 'Delete');
      expect(AppStrings.submit, 'Submit');
      expect(AppStrings.statusApproved, 'Approved');
      expect(AppStrings.statusPending, 'Pending');
      expect(AppStrings.statusPaid, 'Paid');
      expect(AppStrings.statusOverdue, 'Overdue');
    });
  });
}
