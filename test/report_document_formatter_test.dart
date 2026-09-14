import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/utils/gpa_calculator.dart';
import 'package:school_management_system/core/utils/report_document_formatter.dart';

void main() {
  group('ReportDocumentFormatter Academic Transcript Suite', () {
    test('generateStudentTranscript calculates CGPA, credits, and verification code', () {
      final sem1 = SemesterSummary(
        semesterId: 'Fall 2025',
        courses: [
          CourseGrade(subject: 'Mathematics', percentage: 92.0, creditHours: 4.0),
          CourseGrade(subject: 'Physics', percentage: 86.0, creditHours: 3.0),
          CourseGrade(subject: 'English', percentage: 78.0, creditHours: 3.0),
        ],
      );

      final sem2 = SemesterSummary(
        semesterId: 'Spring 2026',
        courses: [
          CourseGrade(subject: 'Chemistry', percentage: 88.0, creditHours: 4.0),
          CourseGrade(subject: 'Computer Science', percentage: 95.0, creditHours: 4.0),
        ],
      );

      final transcript = ReportDocumentFormatter.generateStudentTranscript(
        studentId: 'stu_1001',
        studentName: 'Alex Johnson',
        rollNumber: 'ROLL-1001',
        className: 'Grade 10 - A',
        academicYear: '2025-2026',
        semesters: [sem1, sem2],
      );

      expect(transcript.studentName, 'Alex Johnson');
      expect(transcript.totalCreditsAttempted, 18.0);
      expect(transcript.totalCreditsEarned, 18.0);
      expect(transcript.cumulativeGpa, greaterThan(3.5));
      expect(transcript.verificationCode.length, 8);

      final plainText = transcript.toPlainText();
      expect(plainText.contains('OFFICIAL ACADEMIC TRANSCRIPT'), isTrue);
      expect(plainText.contains('Alex Johnson'), isTrue);
      expect(plainText.contains('Fall 2025'), isTrue);

      final html = transcript.toHtmlPrintable();
      expect(html.contains('<!DOCTYPE html>'), isTrue);
      expect(html.contains('Mathematics'), isTrue);
      expect(html.contains(transcript.verificationCode), isTrue);
    });

    test('generateStudentTranscript sanitizes malicious input tags', () {
      final transcript = ReportDocumentFormatter.generateStudentTranscript(
        studentId: 'stu_xss',
        studentName: 'Evil <script>alert("hack")</script>Student',
        rollNumber: 'R-999',
        className: 'Grade 9</b>',
        academicYear: '2026',
        semesters: [],
      );

      expect(transcript.studentName.contains('<script>'), isFalse);
      expect(transcript.className.contains('</b>'), isFalse);
      expect(transcript.toHtmlPrintable().contains('<script>'), isFalse);
    });
  });

  group('ReportDocumentFormatter Fee Receipt Suite', () {
    test('generateFeeReceipt computes balances and formats full vs partial payments', () {
      final receiptPaid = ReportDocumentFormatter.generateFeeReceipt(
        receiptNumber: 'REC-2026-001',
        studentName: 'Emma Watson',
        rollNumber: 'ROLL-2002',
        className: 'Grade 11 - B',
        feeType: 'Annual Tuition Fee',
        totalAmount: 1200.0,
        amountPaid: 1200.0,
        paymentMethod: 'Credit Card (Stripe)',
        transactionReference: 'txn_983741829',
      );

      expect(receiptPaid.balanceDue, 0.0);
      expect(receiptPaid.isFullyPaid, isTrue);

      final plainText = receiptPaid.toPlainText();
      expect(plainText.contains('PAID IN FULL'), isTrue);
      expect(plainText.contains('\$1200.00'), isTrue);

      final html = receiptPaid.toHtmlPrintable();
      expect(html.contains('badge-paid'), isTrue);
      expect(html.contains('txn_983741829'), isTrue);

      final receiptPartial = ReportDocumentFormatter.generateFeeReceipt(
        receiptNumber: 'REC-2026-002',
        studentName: 'David Miller',
        rollNumber: 'ROLL-2003',
        className: 'Grade 9 - A',
        feeType: 'Lab & Activity Fee',
        totalAmount: 500.0,
        amountPaid: 200.0,
        paymentMethod: 'Bank Transfer',
        transactionReference: 'txn_7721831',
      );

      expect(receiptPartial.balanceDue, 300.0);
      expect(receiptPartial.isFullyPaid, isFalse);
      expect(receiptPartial.toPlainText().contains('PARTIAL PAYMENT'), isTrue);
      expect(receiptPartial.toHtmlPrintable().contains('badge-partial'), isTrue);
    });
  });

  group('ReportDocumentFormatter Attendance Certificate Suite', () {
    test('generateAttendanceCertificate categorizes exemplary vs warning compliance', () {
      final certExemplary = ReportDocumentFormatter.generateAttendanceCertificate(
        studentName: 'Sophia Clark',
        rollNumber: 'ROLL-3001',
        className: 'Grade 12 - A',
        academicYear: '2025-2026',
        totalSchoolDays: 200,
        presentDays: 196,
        longestStreak: 84,
      );

      expect(certExemplary.attendancePercentage, 98.0);
      expect(certExemplary.absentDays, 4);
      expect(certExemplary.complianceStatus.contains('Exemplary'), isTrue);

      final certText = certExemplary.toPlainText();
      expect(certText.contains('ATTENDANCE RECORD CERTIFICATION'), isTrue);
      expect(certText.contains('84 days'), isTrue);

      final certWarning = ReportDocumentFormatter.generateAttendanceCertificate(
        studentName: 'Late Student',
        rollNumber: 'ROLL-3002',
        className: 'Grade 10 - C',
        academicYear: '2025-2026',
        totalSchoolDays: 100,
        presentDays: 68,
      );

      expect(certWarning.attendancePercentage, 68.0);
      expect(certWarning.absentDays, 32);
      expect(certWarning.complianceStatus.contains('Warning'), isTrue);
    });
  });
}
