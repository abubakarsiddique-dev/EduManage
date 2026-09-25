/// Functional extensions on [Iterable] and [List] for batching and filtering.
extension EduIterableX<T> on Iterable<T> {
  /// Splits the iterable into chunks of size [chunkSize].
  List<List<T>> chunk(int chunkSize) {
    if (chunkSize <= 0) throw ArgumentError('chunkSize must be greater than 0');
    final chunks = <List<T>>[];
    final list = toList();
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, (i + chunkSize > list.length) ? list.length : i + chunkSize));
    }
    return chunks;
  }

  /// Filters duplicate elements according to a key selector function.
  List<T> distinctBy<K>(K Function(T element) keySelector) {
    final seen = <K>{};
    final result = <T>[];
    for (final element in this) {
      final key = keySelector(element);
      if (seen.add(key)) {
        result.add(element);
      }
    }
    return result;
  }

  /// Partitions items into two lists: matching predicate and non-matching.
  (List<T> matching, List<T> nonMatching) partition(bool Function(T element) predicate) {
    final matching = <T>[];
    final nonMatching = <T>[];
    for (final element in this) {
      if (predicate(element)) {
        matching.add(element);
      } else {
        nonMatching.add(element);
      }
    }
    return (matching, nonMatching);
  }
}
