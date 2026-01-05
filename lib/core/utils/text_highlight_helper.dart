/// Segment representing highlighted or unhighlighted slice of text.
class TextSpanSegment {
  final String text;
  final bool isMatch;

  const TextSpanSegment({required this.text, required this.isMatch});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSpanSegment &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isMatch == other.isMatch;

  @override
  int get hashCode => text.hashCode ^ isMatch.hashCode;

  @override
  String toString() => 'TextSpanSegment(text: "$text", isMatch: $isMatch)';
}

/// Helper for highlighting search query terms within text strings.
class TextHighlightHelper {
  TextHighlightHelper._();

  /// Splits [sourceText] into matching and non-matching segments based on [searchTerm].
  static List<TextSpanSegment> splitForHighlight(String sourceText, String searchTerm) {
    if (sourceText.isEmpty) return const [];
    if (searchTerm.trim().isEmpty) {
      return [TextSpanSegment(text: sourceText, isMatch: false)];
    }

    final segments = <TextSpanSegment>[];
    final escapedTerm = RegExp.escape(searchTerm.trim());
    final regex = RegExp(escapedTerm, caseSensitive: false);

    var lastIndex = 0;
    for (final match in regex.allMatches(sourceText)) {
      if (match.start > lastIndex) {
        segments.add(TextSpanSegment(
          text: sourceText.substring(lastIndex, match.start),
          isMatch: false,
        ));
      }
      segments.add(TextSpanSegment(
        text: sourceText.substring(match.start, match.end),
        isMatch: true,
      ));
      lastIndex = match.end;
    }

    if (lastIndex < sourceText.length) {
      segments.add(TextSpanSegment(
        text: sourceText.substring(lastIndex),
        isMatch: false,
      ));
    }

    return segments;
  }
}
