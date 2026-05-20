/// Campus security alert tiers, lockdown codes, and emergency assembly stations.
class EmergencyProtocolCodes {
  EmergencyProtocolCodes._();

  static const String codeRed = 'CODE_RED'; // Immediate security threat / intruder
  static const String codeBlue = 'CODE_BLUE'; // Severe medical emergency on campus
  static const String codeYellow = 'CODE_YELLOW'; // Severe weather / regional advisory
  static const String codeGreen = 'CODE_GREEN'; // All clear / normal operations resume
  static const String drillFire = 'DRILL_FIRE'; // Scheduled evacuation drill

  static const Map<String, String> instructions = {
    codeRed: 'Lock all classroom doors, extinguish lights, and remain silent away from windows.',
    codeBlue: 'Dispatch first responder team and clearance stretcher to the incident location.',
    codeYellow: 'Remain indoors, cancel outdoor sports, and monitor weather radar updates.',
    codeGreen: 'Threat resolved. Normal class schedules and movements may resume.',
    drillFire: 'Evacuate systematically via designated fire stairwells to Assembly Ground B.',
  };

  static String getDirective(String code, [String fallback = 'Follow standard campus safety protocols.']) {
    return instructions[code] ?? fallback;
  }
}
