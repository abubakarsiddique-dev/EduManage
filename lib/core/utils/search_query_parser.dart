/// Structured search query containing raw terms, key-value filter tags, and quoted phrases.
class ParsedSearchQuery {
  final List<String> terms;
  final Map<String, String> tags;
  final List<String> phrases;

  const ParsedSearchQuery({
    this.terms = const [],
    this.tags = const {},
    this.phrases = const [],
  });

  bool get isEmpty => terms.isEmpty && tags.isEmpty && phrases.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

/// Tokenizes search input strings containing key:value filters and quoted exact-match phrases.
class SearchQueryParser {
  SearchQueryParser._();

  /// Parses an input string (e.g., 'physics class:10-A "term 2"') into structured components.
  static ParsedSearchQuery parse(String rawQuery) {
    if (rawQuery.trim().isEmpty) {
      return const ParsedSearchQuery();
    }

    final terms = <String>[];
    final tags = <String, String>{};
    final phrases = <String>[];

    // 1. Extract quoted phrases: "..."
    final phraseRegex = RegExp(r'"([^"]*)"');
    var cleanedQuery = rawQuery;
    final phraseMatches = phraseRegex.allMatches(rawQuery);
    for (final match in phraseMatches) {
      final phrase = match.group(1)?.trim();
      if (phrase != null && phrase.isNotEmpty) {
        phrases.add(phrase);
      }
    }
    cleanedQuery = cleanedQuery.replaceAll(phraseRegex, ' ');

    // 2. Extract key:value tags (e.g. status:paid, class:10-A)
    final tagRegex = RegExp(r'(\b\w+):([^\s]+)');
    final tagMatches = tagRegex.allMatches(cleanedQuery);
    for (final match in tagMatches) {
      final key = match.group(1)?.toLowerCase();
      final value = match.group(2);
      if (key != null && value != null) {
        tags[key] = value;
      }
    }
    cleanedQuery = cleanedQuery.replaceAll(tagRegex, ' ');

    // 3. Extract remaining plain tokens
    final tokens = cleanedQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    terms.addAll(tokens);

    return ParsedSearchQuery(
      terms: terms,
      tags: tags,
      phrases: phrases,
    );
  }
}
