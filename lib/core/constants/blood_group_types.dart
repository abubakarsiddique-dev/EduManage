/// Standard blood group taxonomy and compatibility mapping for campus medical clinics.
class BloodGroupTypes {
  BloodGroupTypes._();

  static const String aPositive = 'A+';
  static const String aNegative = 'A-';
  static const String bPositive = 'B+';
  static const String bNegative = 'B-';
  static const String abPositive = 'AB+';
  static const String abNegative = 'AB-';
  static const String oPositive = 'O+';
  static const String oNegative = 'O-';

  static const List<String> all = [
    aPositive,
    aNegative,
    bPositive,
    bNegative,
    abPositive,
    abNegative,
    oPositive,
    oNegative,
  ];

  /// Checks if a blood group is a universal red blood cell donor (O-).
  static bool isUniversalDonor(String group) => group.trim().toUpperCase() == oNegative;

  /// Checks if a blood group is a universal recipient (AB+).
  static bool isUniversalRecipient(String group) => group.trim().toUpperCase() == abPositive;

  /// Validates whether a provided string is a recognized blood group.
  static bool isValid(String group) => all.contains(group.trim().toUpperCase());
}
