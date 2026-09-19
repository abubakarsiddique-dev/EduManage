/// Sort direction for collection ordering.
enum SortOrder { ascending, descending }

/// Specification for sorting items of type [T] by a selected property.
class SortCriterion<T> {
  final Comparable<dynamic>? Function(T item) selector;
  final SortOrder order;
  final bool nullsLast;

  const SortCriterion({
    required this.selector,
    this.order = SortOrder.ascending,
    this.nullsLast = true,
  });

  int compare(T a, T b) {
    final valA = selector(a);
    final valB = selector(b);

    if (valA == null && valB == null) return 0;
    if (valA == null) return nullsLast ? 1 : -1;
    if (valB == null) return nullsLast ? -1 : 1;

    final comparison = valA.compareTo(valB);
    return order == SortOrder.ascending ? comparison : -comparison;
  }
}

/// A filter rule that evaluates whether an item of type [T] satisfies a condition.
class FilterPredicate<T> {
  final bool Function(T item) _test;
  final String? description;

  const FilterPredicate(this._test, {this.description});

  bool matches(T item) => _test(item);

  /// Matches when the extracted value exactly equals [targetValue].
  factory FilterPredicate.equals(
    Object? Function(T item) extractor,
    Object? targetValue, {
    String? description,
  }) {
    return FilterPredicate(
      (item) => extractor(item) == targetValue,
      description: description ?? 'equals($targetValue)',
    );
  }

  /// Matches when the extracted value is contained within [allowedValues].
  factory FilterPredicate.inList(
    Object? Function(T item) extractor,
    Iterable<Object?> allowedValues, {
    String? description,
  }) {
    final set = allowedValues.toSet();
    return FilterPredicate(
      (item) => set.contains(extractor(item)),
      description: description ?? 'inList(${allowedValues.length} items)',
    );
  }

  /// Matches when a numeric extracted value falls within [min] and [max] (inclusive).
  factory FilterPredicate.range(
    num? Function(T item) extractor, {
    num? min,
    num? max,
    String? description,
  }) {
    return FilterPredicate((item) {
      final val = extractor(item);
      if (val == null) return false;
      if (min != null && val < min) return false;
      if (max != null && val > max) return false;
      return true;
    }, description: description ?? 'range(min: $min, max: $max)');
  }

  /// Matches when a DateTime falls within [start] and [end] (inclusive).
  factory FilterPredicate.dateBetween(
    DateTime? Function(T item) extractor, {
    DateTime? start,
    DateTime? end,
    String? description,
  }) {
    return FilterPredicate((item) {
      final date = extractor(item);
      if (date == null) return false;
      if (start != null && date.isBefore(start)) return false;
      if (end != null && date.isAfter(end)) return false;
      return true;
    }, description: description ?? 'dateBetween(start: $start, end: $end)');
  }

  /// Custom arbitrary boolean condition.
  factory FilterPredicate.custom(
    bool Function(T item) test, {
    String? description,
  }) {
    return FilterPredicate(test, description: description);
  }
}

/// Represents the output of a paginated search & filter pipeline execution.
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  int get totalPages => pageSize > 0 ? (totalCount / pageSize).ceil() : 0;
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

/// High-performance client-side search, multi-criteria filtering, sorting,
/// faceted aggregation, and pagination engine for domain model collections.
class SearchFilterEngine<T> {
  const SearchFilterEngine();

  /// Filters [items] by requiring all [predicates] to evaluate to true.
  List<T> filter(List<T> items, List<FilterPredicate<T>> predicates) {
    if (predicates.isEmpty) return List<T>.from(items);

    return items.where((item) {
      for (final predicate in predicates) {
        if (!predicate.matches(item)) return false;
      }
      return true;
    }).toList();
  }

  /// Performs tokenized, case-insensitive text search across multiple string extractors.
  List<T> search(
    List<T> items,
    String? query,
    List<String? Function(T item)> extractors, {
    bool matchAllTokens = true,
  }) {
    if (query == null || query.trim().isEmpty) {
      return List<T>.from(items);
    }

    final tokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) return List<T>.from(items);

    return items.where((item) {
      final values = extractors
          .map((ext) => ext(item)?.toLowerCase() ?? '')
          .toList();

      if (matchAllTokens) {
        // AND: each token must match at least one extracted value
        return tokens.every((token) => values.any((v) => v.contains(token)));
      } else {
        // OR: at least one token must match at least one extracted value
        return tokens.any((token) => values.any((v) => v.contains(token)));
      }
    }).toList();
  }

  /// Applies multi-level sequential sorting across one or more [SortCriterion].
  List<T> sort(List<T> items, List<SortCriterion<T>> criteria) {
    if (criteria.isEmpty) return List<T>.from(items);

    final sorted = List<T>.from(items);
    sorted.sort((a, b) {
      for (final criterion in criteria) {
        final result = criterion.compare(a, b);
        if (result != 0) return result;
      }
      return 0;
    });
    return sorted;
  }

  /// Slices [items] into a paginated subset.
  PagedResult<T> paginate(List<T> items, {int page = 1, int pageSize = 20}) {
    final validPage = page < 1 ? 1 : page;
    final validPageSize = pageSize < 1 ? 1 : pageSize;
    final totalCount = items.length;

    final startIndex = (validPage - 1) * validPageSize;
    if (startIndex >= totalCount) {
      return PagedResult(
        items: const [],
        totalCount: totalCount,
        page: validPage,
        pageSize: validPageSize,
      );
    }

    final endIndex = (startIndex + validPageSize).clamp(0, totalCount);
    final pagedItems = items.sublist(startIndex, endIndex);

    return PagedResult(
      items: pagedItems,
      totalCount: totalCount,
      page: validPage,
      pageSize: validPageSize,
    );
  }

  /// Executes the complete pipeline: search -> filter -> sort -> paginate.
  PagedResult<T> execute({
    required List<T> items,
    String? query,
    List<String? Function(T item)>? searchExtractors,
    List<FilterPredicate<T>>? predicates,
    List<SortCriterion<T>>? sortCriteria,
    int page = 1,
    int pageSize = 20,
    bool matchAllTokens = true,
  }) {
    List<T> result = items;

    // 1. Text search
    if (query != null && query.trim().isNotEmpty && searchExtractors != null) {
      result = search(
        result,
        query,
        searchExtractors,
        matchAllTokens: matchAllTokens,
      );
    }

    // 2. Structured predicates
    if (predicates != null && predicates.isNotEmpty) {
      result = filter(result, predicates);
    }

    // 3. Multi-level sorting
    if (sortCriteria != null && sortCriteria.isNotEmpty) {
      result = sort(result, sortCriteria);
    }

    // 4. Pagination
    return paginate(result, page: page, pageSize: pageSize);
  }

  /// Computes grouped count frequencies of an extracted categorical facet property.
  Map<F, int> computeFacetCounts<F>(
    List<T> items,
    F? Function(T item) facetExtractor,
  ) {
    final counts = <F, int>{};
    for (final item in items) {
      final facet = facetExtractor(item);
      if (facet != null) {
        counts[facet] = (counts[facet] ?? 0) + 1;
      }
    }
    return counts;
  }
}
