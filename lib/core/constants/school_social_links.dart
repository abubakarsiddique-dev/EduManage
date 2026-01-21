/// Standardized social media, portal links, and emergency support channels for the institution.
class SchoolSocialLinks {
  SchoolSocialLinks._();

  static const String website = 'https://edumanage.school.edu';
  static const String studentPortal = 'https://portal.edumanage.school.edu';
  static const String libraryPortal = 'https://library.edumanage.school.edu';

  static const String supportEmail = 'support@edumanage.school.edu';
  static const String admissionsEmail = 'admissions@edumanage.school.edu';
  static const String helplinePhone = '+92-42-111-EDU-MNG';

  static const String facebook = 'https://facebook.com/EduManageOfficial';
  static const String twitter = 'https://twitter.com/EduManageSchool';
  static const String youtube = 'https://youtube.com/@EduManageSchool';
  static const String linkedin = 'https://linkedin.com/company/edumanage-school';

  /// Validates whether a provided URL belongs to official school subdomains.
  static bool isOfficialDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.endsWith('edumanage.school.edu');
    } catch (_) {
      return false;
    }
  }
}
