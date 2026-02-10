/// Utility helper for formatting academic ranks, compact currency, and numbers.
class NumberFormatHelper {
  NumberFormatHelper._();

  /// Converts a ranking position to an ordinal string (e.g. 1 -> "1st", 2 -> "2nd", 3 -> "3rd", 4 -> "4th").
  static String toOrdinal(int rank) {
    if (rank <= 0) return '$rank';
    final mod100 = rank % 100;
    if (mod100 >= 11 && mod100 <= 13) {
      return '${rank}th';
    }
    switch (rank % 10) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }

  /// Compacts large numbers (e.g. 1500 -> "1.5K", 2500000 -> "2.5M").
  static String toCompact(num number) {
    final abs = number.abs();
    final sign = number < 0 ? '-' : '';
    if (abs >= 1000000) {
      final value = (abs / 1000000).toStringAsFixed(1);
      return '$sign${_cleanTrailingZero(value)}M';
    } else if (abs >= 1000) {
      final value = (abs / 1000).toStringAsFixed(1);
      return '$sign${_cleanTrailingZero(value)}K';
    }
    return '$number';
  }

  static String _cleanTrailingZero(String formatted) {
    if (formatted.endsWith('.0')) {
      return formatted.substring(0, formatted.length - 2);
    }
    return formatted;
  }
}
