import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_management_system/data/models/assignment_model.dart';
import 'package:school_management_system/data/models/attendence_model.dart';
import 'package:school_management_system/data/models/class_model.dart';
import 'package:school_management_system/data/models/fee_model.dart';
import 'package:school_management_system/data/models/notice_model.dart';
import 'package:school_management_system/data/models/result_model.dart';
import 'package:school_management_system/data/models/student_model.dart';
import 'package:school_management_system/data/models/teacher_model.dart';
import 'package:school_management_system/data/models/timetable_model.dart';

void main() {
  group('AssignmentModel Tests', () {
    test('serializes and deserializes map correctly', () {
      final dueDate = DateTime(2026, 10, 15);
      final assignment = AssignmentModel(
        id: 'assign_123',
        title: 'Math Homework 1',
        description: 'Complete chapter 4 exercises 1-10',
        subject: 'Mathematics',
        className: 'Grade 10 - A',
        dueDate: dueDate,
        teacherId: 'teacher_99',
        teacherName: 'Prof. Smith',
        totalMarks: 50.0,
      );

      final map = assignment.toMap();
      expect(map['title'], 'Math Homework 1');
      expect(map['subject'], 'Mathematics');
      expect(map['className'], 'Grade 10 - A');
      expect(map['teacherId'], 'teacher_99');
      expect(map['teacherName'], 'Prof. Smith');
      expect(map['totalMarks'], 50.0);

      final parsed = AssignmentModel.fromMap('assign_123', {
        'title': 'Math Homework 1',
        'description': 'Complete chapter 4 exercises 1-10',
        'subject': 'Mathematics',
        'className': 'Grade 10 - A',
        'dueDate': Timestamp.fromDate(dueDate),
        'teacherId': 'teacher_99',
        'teacherName': 'Prof. Smith',
        'totalMarks': 50.0,
      });

      expect(parsed.id, 'assign_123');
      expect(parsed.title, 'Math Homework 1');
      expect(parsed.dueDate, dueDate);
      expect(parsed.formattedDueDate, 'Oct 15, 2026');
    });

    test('overdue calculation is accurate', () {
      final pastDue = AssignmentModel(
        id: '1',
        title: 'Past Assignment',
        subject: 'Physics',
        className: 'Grade 9 - A',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        teacherId: 't1',
      );
      expect(pastDue.isOverdue, isTrue);

      final futureDue = AssignmentModel(
        id: '2',
        title: 'Future Assignment',
        subject: 'Physics',
        className: 'Grade 9 - A',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        teacherId: 't1',
      );
      expect(futureDue.isOverdue, isFalse);
    });
  });

  group('ClassModel Tests', () {
    test('serializes and deserializes class data correctly', () {
      final classModel = ClassModel(
        id: 'cls_001',
        name: 'Grade 9 - B',
        classTeacher: 'Mr. Anderson',
        classTeacherId: 'teacher_42',
        room: 'Room 204',
        capacity: 35,
      );

      final map = classModel.toMap();
      expect(map['name'], 'Grade 9 - B');
      expect(map['classTeacher'], 'Mr. Anderson');
      expect(map['classTeacherId'], 'teacher_42');
      expect(map['room'], 'Room 204');
      expect(map['capacity'], 35);

      final parsed = ClassModel.fromMap('cls_001', map);
      expect(parsed.id, 'cls_001');
      expect(parsed.name, 'Grade 9 - B');
      expect(parsed.classTeacher, 'Mr. Anderson');
      expect(parsed.room, 'Room 204');
      expect(parsed.capacity, 35);
    });

    test('value equality and copyWith work properly', () {
      final classModel = ClassModel(
        id: 'cls_001',
        name: 'Grade 9 - B',
        classTeacher: 'Mr. Anderson',
        room: 'Room 204',
        capacity: 35,
      );
      final identicalClone = ClassModel(
        id: 'cls_001',
        name: 'Grade 9 - B',
        classTeacher: 'Mr. Anderson',
        room: 'Room 204',
        capacity: 35,
      );

      expect(classModel, equals(identicalClone));
      expect(classModel.hashCode, equals(identicalClone.hashCode));

      final modified = classModel.copyWith(room: 'Room 305');
      expect(modified.room, 'Room 305');
      expect(classModel, isNot(equals(modified)));
    });
  });


  group('FeeModel Tests', () {
    test('handles fee statuses and overdue tracking', () {
      final fee = FeeModel(
        id: 'fee_01',
        studentId: 'std_55',
        studentName: 'Alice Johnson',
        className: 'Grade 10 - A',
        amount: 4500,
        status: FeeStatus.pending,
        dueDate: DateTime(2025, 1, 1),
      );

      expect(fee.isOverdue, isTrue);
      expect(fee.formattedAmount, 'Rs. 4500');

      final paidFee = fee.copyWith(status: FeeStatus.paid);
      expect(paidFee.isOverdue, isFalse);
      expect(paidFee.status, FeeStatus.paid);
    });

    test('fee status parser maps string variants correctly', () {
      expect(feeStatusFromString('paid'), FeeStatus.paid);
      expect(feeStatusFromString('pending'), FeeStatus.pending);
      expect(feeStatusFromString('overdue'), FeeStatus.overdue);
      expect(feeStatusFromString('pending_verification'), FeeStatus.pendingVerification);
      expect(feeStatusFromString('pendingVerification'), FeeStatus.pendingVerification);
      expect(feeStatusFromString('invalid'), FeeStatus.unknown);
    });
  });

  group('TimetableModel Tests', () {
    test('formats time ranges and serializes properties', () {
      final slot = TimetableModel(
        id: 'slot_1',
        className: 'Grade 8 - A',
        day: 'Monday',
        subject: 'English',
        teacher: 'Ms. Davis',
        startTime: '08:30 AM',
        endTime: '09:15 AM',
        room: 'Lab 1',
      );

      expect(slot.timeRange, '08:30 AM - 09:15 AM');

      final map = slot.toMap();
      expect(map['className'], 'Grade 8 - A');
      expect(map['day'], 'Monday');
      expect(map['subject'], 'English');
      expect(map['startTime'], '08:30 AM');
      expect(map['endTime'], '09:15 AM');
    });
  });

  group('ResultModel Tests', () {
    test('computes letter grades accurately', () {
      final aPlus = ResultModel(
        id: '1',
        studentId: 's1',
        studentName: 'Bob',
        className: 'Grade 9 - A',
        subject: 'Biology',
        examTitle: 'Midterm',
        marksObtained: 95,
        totalMarks: 100,
        percentage: 95,
      );
      expect(aPlus.letterGrade, 'A+');

      final bGrade = aPlus.copyWith(percentage: 65, marksObtained: 65);
      expect(bGrade.letterGrade, 'B');

      final fGrade = aPlus.copyWith(percentage: 35, marksObtained: 35);
      expect(fGrade.letterGrade, 'F');
    });
  });

  group('AttendanceModel Tests', () {
    test('maps attendance status correctly', () {
      expect(attendanceStatusFromString('present'), AttendanceStatusValue.present);
      expect(attendanceStatusFromString('absent'), AttendanceStatusValue.absent);
      expect(attendanceStatusFromString('late'), AttendanceStatusValue.late);
      expect(attendanceStatusFromString('leave'), AttendanceStatusValue.leave);
      expect(attendanceStatusFromString('unknown'), AttendanceStatusValue.unmarked);
    });
  });

  group('NoticeModel Tests', () {
    final sampleDate = DateTime(2026, 9, 24, 8, 30);
    final notice = NoticeModel(
      id: 'notice_01',
      title: 'Annual Sports Gala',
      body: 'The annual sports gala will commence next Monday.',
      category: 'Event',
      author: 'Principal Office',
      createdAt: sampleDate,
    );

    test('serializes and deserializes correctly', () {
      final map = notice.toMap();
      expect(map['title'], 'Annual Sports Gala');
      expect(map['body'], 'The annual sports gala will commence next Monday.');
      expect(map['category'], 'Event');
      expect(map['author'], 'Principal Office');

      final fromMap = NoticeModel.fromMap('notice_01', {
        'title': 'Annual Sports Gala',
        'body': 'The annual sports gala will commence next Monday.',
        'category': 'Event',
        'author': 'Principal Office',
        'createdAt': Timestamp.fromDate(sampleDate),
      });

      expect(fromMap.id, 'notice_01');
      expect(fromMap.title, notice.title);
      expect(fromMap.category, notice.category);
      expect(fromMap.description, notice.body);
      expect(fromMap.dateLabel, 'Sep 24');
    });

    test('copyWith modifies targeted attributes and preserves others', () {
      final updated = notice.copyWith(
        title: 'Updated Gala Schedule',
        category: 'General',
      );

      expect(updated.id, 'notice_01');
      expect(updated.title, 'Updated Gala Schedule');
      expect(updated.category, 'General');
      expect(updated.body, notice.body);
      expect(updated.author, notice.author);
      expect(updated.createdAt, notice.createdAt);
    });

    test('value equality and hashCode operate correctly', () {
      final noticeClone = NoticeModel(
        id: 'notice_01',
        title: 'Annual Sports Gala',
        body: 'The annual sports gala will commence next Monday.',
        category: 'Event',
        author: 'Principal Office',
        createdAt: sampleDate,
      );

      expect(notice, equals(noticeClone));
      expect(notice.hashCode, equals(noticeClone.hashCode));

      final differentNotice = notice.copyWith(id: 'notice_02');
      expect(notice, isNot(equals(differentNotice)));
    });
  });

  group('TeacherModel Tests', () {
    test('serializes and deserializes correctly', () {
      final teacher = TeacherModel(
        id: 'teach_01',
        name: 'Prof. John Doe',
        email: 'john.doe@school.edu',
        phone: '+92 300 1234567',
        subject: 'Mathematics',
        qualification: 'M.Sc Mathematics',
        classes: ['Grade 9 - A', 'Grade 10 - B'],
        approved: true,
      );

      final map = teacher.toMap();
      expect(map['uid'], 'teach_01');
      expect(map['name'], 'Prof. John Doe');
      expect(map['subject'], 'Mathematics');
      expect(map['classes'], ['Grade 9 - A', 'Grade 10 - B']);

      final parsed = TeacherModel.fromMap('teach_01', {
        'name': 'Prof. John Doe',
        'email': 'john.doe@school.edu',
        'phone': '+92 300 1234567',
        'subject': 'Mathematics',
        'qualification': 'M.Sc Mathematics',
        'classes': ['Grade 9 - A', 'Grade 10 - B'],
        'approved': true,
      });

      expect(parsed.id, 'teach_01');
      expect(parsed.name, 'Prof. John Doe');
      expect(parsed.classesFormatted, 'Grade 9 - A, Grade 10 - B');
    });

    test('classesFormatted handles empty class list', () {
      const teacher = TeacherModel(
        id: 't2',
        name: 'Jane',
        email: 'jane@school.edu',
        phone: '123',
        subject: 'Physics',
        qualification: 'B.Sc',
        classes: [],
      );
      expect(teacher.classesFormatted, 'No classes assigned');
    });

    test('value equality, copyWith, and hashCode operate accurately', () {
      final teacher1 = TeacherModel(
        id: 't1',
        name: 'Sir Isaac',
        email: 'isaac@school.edu',
        phone: '111',
        subject: 'Physics',
        qualification: 'Ph.D',
        classes: ['10-A'],
      );
      final teacherClone = TeacherModel(
        id: 't1',
        name: 'Sir Isaac',
        email: 'isaac@school.edu',
        phone: '111',
        subject: 'Physics',
        qualification: 'Ph.D',
        classes: ['10-A'],
      );

      expect(teacher1, equals(teacherClone));
      expect(teacher1.hashCode, equals(teacherClone.hashCode));

      final updated = teacher1.copyWith(subject: 'Advanced Physics');
      expect(updated.subject, 'Advanced Physics');
      expect(teacher1, isNot(equals(updated)));
    });
  });

  group('StudentModel Tests', () {
    test('serializes and deserializes student document map correctly', () {
      final student = StudentModel(
        id: 'std_99',
        name: 'Sara Khan',
        email: 'sara.khan@student.edu',
        rollNo: 'STD-2026-099',
        className: 'Grade 10',
        section: 'B',
        contact: '+92 300 7654321',
        approved: true,
      );

      final map = student.toMap();
      expect(map['uid'], 'std_99');
      expect(map['name'], 'Sara Khan');
      expect(map['rollNo'], 'STD-2026-099');
      expect(map['class'], 'Grade 10');
      expect(map['section'], 'B');

      final fromMap = StudentModel.fromMap('std_99', {
        'name': 'Sara Khan',
        'email': 'sara.khan@student.edu',
        'rollNo': 'STD-2026-099',
        'class': 'Grade 10',
        'section': 'B',
        'contact': '+92 300 7654321',
        'approved': true,
      });

      expect(fromMap.id, 'std_99');
      expect(fromMap.name, 'Sara Khan');
      expect(fromMap.fullClassSection, 'Grade 10 - B');
    });

    test('value equality, copyWith, and hashCode work as expected', () {
      final s1 = StudentModel(
        id: 's1',
        name: 'Ali',
        email: 'ali@student.edu',
        rollNo: 'R-01',
        className: 'Grade 9',
        section: 'A',
        contact: '0300',
      );
      final sClone = StudentModel(
        id: 's1',
        name: 'Ali',
        email: 'ali@student.edu',
        rollNo: 'R-01',
        className: 'Grade 9',
        section: 'A',
        contact: '0300',
      );

      expect(s1, equals(sClone));
      expect(s1.hashCode, equals(sClone.hashCode));

      final sUpdated = s1.copyWith(section: 'B');
      expect(sUpdated.section, 'B');
      expect(s1, isNot(equals(sUpdated)));
    });
  });
}



