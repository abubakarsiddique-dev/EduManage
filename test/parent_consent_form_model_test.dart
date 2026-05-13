import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/parent_consent_form_model.dart';

void main() {
  group('ParentConsentFormModel Tests', () {
    test('status predicates evaluate correctly', () {
      final consent = ParentConsentFormModel(
        id: 'cf1',
        title: 'Lahore Museum Educational Visit',
        studentId: 's10',
        parentId: 'p10',
        eventDetails: 'Bus departs 08:30 AM',
        deadline: DateTime(2026, 5, 18),
        status: ConsentStatus.granted,
      );

      expect(consent.isGranted, isTrue);
      expect(consent.isPending, isFalse);
    });

    test('serialization roundtrip preserves timestamp and status', () {
      final map = {
        'title': 'Swimming Gala Participation',
        'studentId': 's25',
        'parentId': 'p25',
        'eventDetails': 'Inter-school competition',
        'deadline': DateTime(2026, 5, 25).toIso8601String(),
        'status': 'granted',
        'signedAt': DateTime(2026, 5, 13, 14, 0).toIso8601String(),
      };

      final model = ParentConsentFormModel.fromMap('cf25', map);
      expect(model.status, ConsentStatus.granted);
      expect(model.signedAt, isNotNull);
    });
  });
}
