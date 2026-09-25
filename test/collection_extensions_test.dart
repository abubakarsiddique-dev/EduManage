import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/collection_extensions.dart';

void main() {
  group('CollectionExtensions Tests', () {
    test('chunk partitions list into sublists of specified size', () {
      final list = [1, 2, 3, 4, 5, 6, 7];
      final chunks = list.chunk(3);
      expect(chunks.length, 3);
      expect(chunks[0], [1, 2, 3]);
      expect(chunks[1], [4, 5, 6]);
      expect(chunks[2], [7]);
    });

    test('distinctBy extracts unique items according to key', () {
      final items = [
        {'id': 1, 'name': 'Alpha'},
        {'id': 2, 'name': 'Beta'},
        {'id': 1, 'name': 'Alpha Clone'},
      ];
      final unique = items.distinctBy((e) => e['id']);
      expect(unique.length, 2);
      expect(unique.map((e) => e['name']).toList(), ['Alpha', 'Beta']);
    });

    test('partition divides items based on predicate condition', () {
      final numbers = [1, 2, 3, 4, 5, 6];
      final (evens, odds) = numbers.partition((n) => n % 2 == 0);
      expect(evens, [2, 4, 6]);
      expect(odds, [1, 3, 5]);
    });
  });
}
