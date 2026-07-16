import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/scholarship_grant_model.dart';

void main() {
  group('ScholarshipGrantModel Tests', () {
    test('calculateNetFee deducts discount correctly', () {
      final grant = ScholarshipGrantModel(
        id: 'sch1',
        studentId: 'std10',
        studentName: 'Ayesha Khan',
        scholarshipType: ScholarshipType.merit,
        discountPercentage: 50.0,
        approvedBy: 'Director Academic',
        effectiveFrom: DateTime(2026, 1, 1),
        expiresAt: DateTime(2026, 12, 31),
      );

      expect(grant.calculateNetFee(10000.0), 5000.0);
      expect(grant.calculateNetFee(20000.0), 10000.0);
    });

    test('calculateNetFee returns base fee when grant is inactive', () {
      final grant = ScholarshipGrantModel(
        id: 'sch2',
        studentId: 'std11',
        studentName: 'Zainab Bibi',
        scholarshipType: ScholarshipType.sports,
        discountPercentage: 30.0,
        approvedBy: 'Sports Board',
        effectiveFrom: DateTime(2026, 1, 1),
        expiresAt: DateTime(2026, 12, 31),
        isActive: false,
      );

      expect(grant.calculateNetFee(10000.0), 10000.0);
    });
  });
}
