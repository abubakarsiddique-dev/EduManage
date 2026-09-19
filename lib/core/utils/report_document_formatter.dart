import 'gpa_calculator.dart';
import 'security_helper.dart';

/// Formatter generating institutional academic transcripts, fee receipts,
/// and attendance certificates formatted for print media and textual exports.
class ReportDocumentFormatter {
  ReportDocumentFormatter._();

  static const String institutionName = 'EduManage International Academy';
  static const String institutionAddress =
      '100 University Avenue, Academic District';
  static const String institutionContact =
      'contact@edumanage.edu | +1 (555) 019-2834';

  /// Generates an official student academic transcript report.
  static TranscriptDocument generateStudentTranscript({
    required String studentId,
    required String studentName,
    required String rollNumber,
    required String className,
    required String academicYear,
    required List<SemesterSummary> semesters,
  }) {
    final cleanStudentName = SecurityHelper.sanitizeInput(studentName);
    final cleanRollNo = SecurityHelper.sanitizeInput(rollNumber);
    final cleanClassName = SecurityHelper.sanitizeInput(className);
    final cleanYear = SecurityHelper.sanitizeInput(academicYear);

    final cgpa = GpaCalculator.computeCGPA(semesters);
    final standing = GpaCalculator.evaluateStanding(cgpa);

    double totalCreditsAttempted = 0.0;
    double totalCreditsEarned = 0.0;

    for (final sem in semesters) {
      for (final course in sem.courses) {
        totalCreditsAttempted += course.creditHours;
        if (course.gradePoint > 0.0) {
          totalCreditsEarned += course.creditHours;
        }
      }
    }

    // Deterministic FNV-1a verification checksum
    final hashInput =
        '$studentId:$cleanRollNo:$cgpa:$totalCreditsEarned:$cleanYear';
    int hash = 0x811c9dc5;
    for (final unit in hashInput.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    final verificationCode = hash
        .toRadixString(16)
        .padLeft(8, '0')
        .toUpperCase();

    return TranscriptDocument(
      studentId: studentId,
      studentName: cleanStudentName,
      rollNumber: cleanRollNo,
      className: cleanClassName,
      academicYear: cleanYear,
      semesters: semesters,
      cumulativeGpa: cgpa,
      academicStanding: standing,
      totalCreditsAttempted: totalCreditsAttempted,
      totalCreditsEarned: totalCreditsEarned,
      verificationCode: verificationCode,
      generatedAt: DateTime.now().toUtc(),
    );
  }

  /// Generates an official fee payment receipt document.
  static FeeReceiptDocument generateFeeReceipt({
    required String receiptNumber,
    required String studentName,
    required String rollNumber,
    required String className,
    required String feeType,
    required double totalAmount,
    required double amountPaid,
    required String paymentMethod,
    required String transactionReference,
    DateTime? paymentDate,
  }) {
    final cleanReceiptNo = SecurityHelper.sanitizeInput(receiptNumber);
    final cleanStudentName = SecurityHelper.sanitizeInput(studentName);
    final cleanRollNo = SecurityHelper.sanitizeInput(rollNumber);
    final cleanClassName = SecurityHelper.sanitizeInput(className);
    final cleanFeeType = SecurityHelper.sanitizeInput(feeType);
    final cleanPaymentMethod = SecurityHelper.sanitizeInput(paymentMethod);
    final cleanTxRef = SecurityHelper.sanitizeInput(transactionReference);

    final balanceDue = (totalAmount - amountPaid).clamp(0.0, double.infinity);
    final isFullyPaid = balanceDue == 0.0;

    return FeeReceiptDocument(
      receiptNumber: cleanReceiptNo,
      studentName: cleanStudentName,
      rollNumber: cleanRollNo,
      className: cleanClassName,
      feeType: cleanFeeType,
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      balanceDue: balanceDue,
      isFullyPaid: isFullyPaid,
      paymentMethod: cleanPaymentMethod,
      transactionReference: cleanTxRef,
      paymentDate: paymentDate ?? DateTime.now().toUtc(),
    );
  }

  /// Generates an official attendance summary certificate document.
  static AttendanceCertificateDocument generateAttendanceCertificate({
    required String studentName,
    required String rollNumber,
    required String className,
    required String academicYear,
    required int totalSchoolDays,
    required int presentDays,
    int longestStreak = 0,
  }) {
    final cleanStudentName = SecurityHelper.sanitizeInput(studentName);
    final cleanRollNo = SecurityHelper.sanitizeInput(rollNumber);
    final cleanClassName = SecurityHelper.sanitizeInput(className);
    final cleanYear = SecurityHelper.sanitizeInput(academicYear);

    final absentDays = (totalSchoolDays - presentDays).clamp(
      0,
      totalSchoolDays,
    );
    final percentage = totalSchoolDays > 0
        ? (presentDays / totalSchoolDays) * 100
        : 0.0;

    String complianceStatus;
    if (percentage >= 95.0) {
      complianceStatus = 'Exemplary Attendance (Gold Standard)';
    } else if (percentage >= 85.0) {
      complianceStatus = 'Satisfactory Attendance';
    } else if (percentage >= 75.0) {
      complianceStatus = 'Conditional Compliance';
    } else {
      complianceStatus = 'Chronic Absenteeism Warning';
    }

    return AttendanceCertificateDocument(
      studentName: cleanStudentName,
      rollNumber: cleanRollNo,
      className: cleanClassName,
      academicYear: cleanYear,
      totalSchoolDays: totalSchoolDays,
      presentDays: presentDays,
      absentDays: absentDays,
      attendancePercentage: percentage,
      longestStreak: longestStreak,
      complianceStatus: complianceStatus,
      issuedAt: DateTime.now().toUtc(),
    );
  }
}

/// Official academic transcript document model with layout export methods.
class TranscriptDocument {
  final String studentId;
  final String studentName;
  final String rollNumber;
  final String className;
  final String academicYear;
  final List<SemesterSummary> semesters;
  final double cumulativeGpa;
  final AcademicStanding academicStanding;
  final double totalCreditsAttempted;
  final double totalCreditsEarned;
  final String verificationCode;
  final DateTime generatedAt;

  const TranscriptDocument({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.academicYear,
    required this.semesters,
    required this.cumulativeGpa,
    required this.academicStanding,
    required this.totalCreditsAttempted,
    required this.totalCreditsEarned,
    required this.verificationCode,
    required this.generatedAt,
  });

  /// Formats transcript as printable HTML with CSS media print styling.
  String toHtmlPrintable() {
    final semesterTables = semesters
        .map((sem) {
          final rows = sem.courses
              .map((c) {
                return '''
        <tr>
          <td>${c.subject}</td>
          <td style="text-align:center;">${c.creditHours.toStringAsFixed(1)}</td>
          <td style="text-align:center;">${c.percentage.toStringAsFixed(1)}%</td>
          <td style="text-align:center;"><strong>${c.letterGrade}</strong></td>
          <td style="text-align:right;">${c.gradePoint.toStringAsFixed(2)}</td>
        </tr>''';
              })
              .join('\n');

          return '''
      <div class="semester-block">
        <h3>Semester: ${sem.semesterId} (GPA: ${sem.gpa.toStringAsFixed(2)})</h3>
        <table>
          <thead>
            <tr>
              <th>Course / Subject</th>
              <th style="text-align:center;">Credits</th>
              <th style="text-align:center;">Score</th>
              <th style="text-align:center;">Grade</th>
              <th style="text-align:right;">Grade Points</th>
            </tr>
          </thead>
          <tbody>
            $rows
          </tbody>
        </table>
      </div>''';
        })
        .join('\n');

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Academic Transcript - $studentName</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #1e293b; margin: 30px; }
    .header { text-align: center; border-bottom: 2px solid #0f172a; padding-bottom: 12px; margin-bottom: 24px; }
    .header h1 { margin: 0; font-size: 24px; color: #0f172a; }
    .header p { margin: 4px 0; font-size: 13px; color: #64748b; }
    .meta-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 20px; font-size: 14px; }
    .semester-block { margin-bottom: 24px; }
    .semester-block h3 { margin-bottom: 8px; font-size: 15px; color: #1e3a8a; border-bottom: 1px solid #e2e8f0; padding-bottom: 4px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 8px; font-size: 13px; }
    th, td { border: 1px solid #cbd5e1; padding: 8px 10px; }
    th { background: #f8fafc; font-weight: 600; text-align: left; }
    .summary-box { background: #f1f5f9; padding: 14px; border-radius: 6px; margin-top: 20px; font-size: 14px; }
    .footer { margin-top: 40px; display: flex; justify-content: space-between; font-size: 12px; color: #64748b; }
    @media print { body { margin: 0; } }
  </style>
</head>
<body>
  <div class="header">
    <h1>${ReportDocumentFormatter.institutionName}</h1>
    <p>${ReportDocumentFormatter.institutionAddress} | ${ReportDocumentFormatter.institutionContact}</p>
    <h2 style="margin-top:10px; font-size:18px;">OFFICIAL ACADEMIC TRANSCRIPT</h2>
  </div>

  <div class="meta-grid">
    <div><strong>Student Name:</strong> $studentName</div>
    <div><strong>Student ID:</strong> $studentId</div>
    <div><strong>Roll Number:</strong> $rollNumber</div>
    <div><strong>Class / Stream:</strong> $className</div>
    <div><strong>Academic Year:</strong> $academicYear</div>
    <div><strong>Verification Checksum:</strong> <code>$verificationCode</code></div>
  </div>

  $semesterTables

  <div class="summary-box">
    <div><strong>Cumulative GPA (CGPA):</strong> ${cumulativeGpa.toStringAsFixed(2)} / 4.00</div>
    <div><strong>Academic Standing:</strong> ${academicStanding.name}</div>
    <div><strong>Total Credits Earned / Attempted:</strong> ${totalCreditsEarned.toStringAsFixed(1)} / ${totalCreditsAttempted.toStringAsFixed(1)}</div>
  </div>

  <div class="footer">
    <div>Date of Issue: ${generatedAt.toIso8601String().split('T').first}</div>
    <div>Official Registrar Signature: _______________________</div>
  </div>
</body>
</html>''';
  }

  /// Formats transcript as clean text/markdown.
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln(
      '===========================================================',
    );
    buffer.writeln('               OFFICIAL ACADEMIC TRANSCRIPT');
    buffer.writeln('         ${ReportDocumentFormatter.institutionName}');
    buffer.writeln(
      '===========================================================',
    );
    buffer.writeln('Student: $studentName (Roll No: $rollNumber)');
    buffer.writeln('Class: $className | Academic Year: $academicYear');
    buffer.writeln('Verification Hash: $verificationCode');
    buffer.writeln(
      '-----------------------------------------------------------',
    );

    for (final sem in semesters) {
      buffer.writeln(
        'Semester: ${sem.semesterId} (GPA: ${sem.gpa.toStringAsFixed(2)})',
      );
      for (final course in sem.courses) {
        buffer.writeln(
          '  - ${course.subject.padRight(20)}: ${course.percentage.toStringAsFixed(1)}% [${course.letterGrade}] (Pts: ${course.gradePoint.toStringAsFixed(1)})',
        );
      }
      buffer.writeln();
    }

    buffer.writeln(
      '-----------------------------------------------------------',
    );
    buffer.writeln(
      'Cumulative CGPA: ${cumulativeGpa.toStringAsFixed(2)} / 4.00',
    );
    buffer.writeln('Academic Standing: ${academicStanding.name}');
    buffer.writeln(
      'Total Credits: ${totalCreditsEarned.toStringAsFixed(1)} / ${totalCreditsAttempted.toStringAsFixed(1)}',
    );
    buffer.writeln(
      '===========================================================',
    );
    return buffer.toString();
  }
}

/// Official fee receipt document model.
class FeeReceiptDocument {
  final String receiptNumber;
  final String studentName;
  final String rollNumber;
  final String className;
  final String feeType;
  final double totalAmount;
  final double amountPaid;
  final double balanceDue;
  final bool isFullyPaid;
  final String paymentMethod;
  final String transactionReference;
  final DateTime paymentDate;

  const FeeReceiptDocument({
    required this.receiptNumber,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.feeType,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceDue,
    required this.isFullyPaid,
    required this.paymentMethod,
    required this.transactionReference,
    required this.paymentDate,
  });

  /// Formats receipt as printable HTML document.
  String toHtmlPrintable() {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Fee Receipt - $receiptNumber</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, sans-serif; color: #1e293b; margin: 30px; }
    .receipt-card { border: 2px solid #0284c7; padding: 24px; border-radius: 8px; max-width: 650px; margin: auto; }
    .header { text-align: center; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; }
    .title { font-size: 20px; font-weight: bold; color: #0369a1; }
    .receipt-meta { display: flex; justify-content: space-between; margin: 18px 0; font-size: 13px; }
    table { width: 100%; border-collapse: collapse; margin: 16px 0; font-size: 14px; }
    th, td { border-bottom: 1px solid #cbd5e1; padding: 10px; }
    th { text-align: left; background: #f8fafc; }
    .total-row { font-weight: bold; font-size: 15px; }
    .badge { display: inline-block; padding: 4px 10px; border-radius: 4px; font-weight: bold; font-size: 12px; }
    .badge-paid { background: #dcfce7; color: #166534; }
    .badge-partial { background: #fef3c7; color: #92400e; }
  </style>
</head>
<body>
  <div class="receipt-card">
    <div class="header">
      <div class="title">${ReportDocumentFormatter.institutionName}</div>
      <p style="margin:4px 0; font-size:12px; color:#64748b;">OFFICIAL PAYMENT RECEIPT</p>
    </div>

    <div class="receipt-meta">
      <div>
        <strong>Receipt No:</strong> $receiptNumber<br>
        <strong>Student:</strong> $studentName ($rollNumber)<br>
        <strong>Class:</strong> $className
      </div>
      <div style="text-align:right;">
        <strong>Date:</strong> ${paymentDate.toIso8601String().split('T').first}<br>
        <strong>Method:</strong> $paymentMethod<br>
        <strong>Tx Ref:</strong> $transactionReference
      </div>
    </div>

    <table>
      <thead>
        <tr>
          <th>Description</th>
          <th style="text-align:right;">Amount (USD)</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>$feeType</td>
          <td style="text-align:right;">\$${totalAmount.toStringAsFixed(2)}</td>
        </tr>
        <tr>
          <td><strong>Amount Paid:</strong></td>
          <td style="text-align:right; color:#166534;"><strong>\$${amountPaid.toStringAsFixed(2)}</strong></td>
        </tr>
        <tr class="total-row">
          <td>Balance Outstanding:</td>
          <td style="text-align:right;">\$${balanceDue.toStringAsFixed(2)}</td>
        </tr>
      </tbody>
    </table>

    <div style="margin-top:16px; display:flex; justify-content:space-between; align-items:center;">
      <div>
        Status: <span class="badge ${isFullyPaid ? 'badge-paid' : 'badge-partial'}">${isFullyPaid ? 'PAID IN FULL' : 'PARTIAL BALANCE'}</span>
      </div>
      <div style="font-size:12px; color:#64748b;">
        Authorized Bursar Signature: ___________________
      </div>
    </div>
  </div>
</body>
</html>''';
  }

  /// Formats receipt as plain text.
  String toPlainText() {
    return '''
===================================================
             OFFICIAL PAYMENT RECEIPT
       ${ReportDocumentFormatter.institutionName}
===================================================
Receipt No: $receiptNumber
Date: ${paymentDate.toIso8601String().split('T').first}
Student: $studentName (Roll: $rollNumber, Class: $className)
Payment Method: $paymentMethod (Ref: $transactionReference)
---------------------------------------------------
Fee Item: $feeType
Total Invoiced:      \$${totalAmount.toStringAsFixed(2)}
Amount Received:     \$${amountPaid.toStringAsFixed(2)}
Remaining Balance:   \$${balanceDue.toStringAsFixed(2)}
Status:              ${isFullyPaid ? 'PAID IN FULL' : 'PARTIAL PAYMENT'}
===================================================''';
  }
}

/// Official attendance summary certificate document model.
class AttendanceCertificateDocument {
  final String studentName;
  final String rollNumber;
  final String className;
  final String academicYear;
  final int totalSchoolDays;
  final int presentDays;
  final int absentDays;
  final double attendancePercentage;
  final int longestStreak;
  final String complianceStatus;
  final DateTime issuedAt;

  const AttendanceCertificateDocument({
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.academicYear,
    required this.totalSchoolDays,
    required this.presentDays,
    required this.absentDays,
    required this.attendancePercentage,
    required this.longestStreak,
    required this.complianceStatus,
    required this.issuedAt,
  });

  String toPlainText() {
    return '''
===================================================
          ATTENDANCE RECORD CERTIFICATION
       ${ReportDocumentFormatter.institutionName}
===================================================
This is to certify that:
Student Name:        $studentName
Roll Number:         $rollNumber
Class / Grade:       $className
Academic Session:    $academicYear

ATTENDANCE METRICS:
Total Instructional Days: $totalSchoolDays
Days Present:             $presentDays
Days Absent:              $absentDays
Attendance Rate:          ${attendancePercentage.toStringAsFixed(1)}%
Longest Streak:           $longestStreak days
Status:                   $complianceStatus

Date of Certification: ${issuedAt.toIso8601String().split('T').first}
===================================================''';
  }
}
