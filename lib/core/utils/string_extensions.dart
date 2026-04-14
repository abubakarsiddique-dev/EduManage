/// Useful extensions on the [String] class for text formatting and display.
extension EduStringX on String {
  /// Capitalizes the first letter of this string.
  String toCapitalized() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts words separated by spaces into Title Case.
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  /// Extracts uppercase initials from the string (up to maxChars).
  String initials([int maxChars = 2]) {
    if (trim().isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    final result = words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .take(maxChars)
        .join();
    return result;
  }

  /// Masks an email address for privacy (e.g., j***e@domain.com).
  String maskEmail() {
    if (!contains('@')) return this;
    final parts = split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}*@$domain';
    final masked = '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
    return '$masked@$domain';
  }
}
