import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/school_social_links.dart';

void main() {
  group('SchoolSocialLinks Tests', () {
    test('isOfficialDomain validates authorized institutional subdomains', () {
      expect(SchoolSocialLinks.isOfficialDomain('https://portal.edumanage.school.edu/grades'), isTrue);
      expect(SchoolSocialLinks.isOfficialDomain('https://phishing-site.com'), isFalse);
    });

    test('constants have valid URL structure', () {
      expect(SchoolSocialLinks.website.startsWith('https://'), isTrue);
      expect(SchoolSocialLinks.supportEmail.contains('@'), isTrue);
    });
  });
}
