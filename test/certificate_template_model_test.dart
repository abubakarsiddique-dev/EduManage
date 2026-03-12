import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/certificate_template_model.dart';

void main() {
  group('CertificateTemplateModel Tests', () {
    test('serialization roundtrip preserves verification status', () {
      final map = {
        'title': 'High Honors Award',
        'certificateType': 'Academic Merit',
        'issuerName': 'Prof. Usman Malik',
        'issuerDesignation': 'Academic Director',
        'borderStyle': 'modern_emerald',
        'hasQrVerification': true,
      };

      final model = CertificateTemplateModel.fromMap('cert1', map);
      expect(model.title, 'High Honors Award');
      expect(model.hasQrVerification, isTrue);

      final exported = model.toMap();
      expect(exported['issuerDesignation'], 'Academic Director');
    });
  });
}
