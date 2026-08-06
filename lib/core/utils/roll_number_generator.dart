/// Generates standardized, unique academic roll numbers with year, program, and sequence prefix.
class RollNumberGenerator {
  RollNumberGenerator._();

  /// Generates roll numbers formatted like '2026-CS-0042'.
  static String generate({
    required int academicYear,
    required String programCode,
    required int sequenceNumber,
    int padLength = 4,
  }) {
    final cleanCode = programCode.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final paddedSeq = sequenceNumber.toString().padLeft(padLength, '0');
    return '$academicYear-$cleanCode-$paddedSeq';
  }

  /// Parses components from a roll number string.
  static (int? year, String? program, int? sequence) parse(String rollNumber) {
    final parts = rollNumber.split('-');
    if (parts.length != 3) return (null, null, null);
    final year = int.tryParse(parts[0]);
    final program = parts[1];
    final sequence = int.tryParse(parts[2]);
    return (year, program, sequence);
  }
}
