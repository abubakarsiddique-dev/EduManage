import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/search_query_parser.dart';

void main() {
  group('SearchQueryParser Tests', () {
    test('parse handles complex composite queries', () {
      final query = SearchQueryParser.parse('physics class:10-A status:pending "term final"');
      expect(query.terms, ['physics']);
      expect(query.tags['class'], '10-A');
      expect(query.tags['status'], 'pending');
      expect(query.phrases, ['term final']);
    });

    test('parse handles empty or whitespace queries', () {
      final query = SearchQueryParser.parse('   ');
      expect(query.isEmpty, isTrue);
      expect(query.terms, isEmpty);
      expect(query.tags, isEmpty);
      expect(query.phrases, isEmpty);
    });

    test('parse handles plain text without tags', () {
      final query = SearchQueryParser.parse('biology assignments due');
      expect(query.terms, ['biology', 'assignments', 'due']);
      expect(query.tags, isEmpty);
      expect(query.phrases, isEmpty);
    });
  });
}
