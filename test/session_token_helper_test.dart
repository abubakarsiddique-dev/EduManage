import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/session_token_helper.dart';

void main() {
  group('SessionTokenHelper Tests', () {
    test('isTokenExpired checks unix timestamp bounds', () {
      final now = DateTime(2026, 9, 4, 12, 0);
      final futureExp = (DateTime(2026, 9, 4, 13, 0).millisecondsSinceEpoch / 1000).floor();
      final pastExp = (DateTime(2026, 9, 4, 11, 0).millisecondsSinceEpoch / 1000).floor();

      expect(SessionTokenHelper.isTokenExpired(futureExp, now), isFalse);
      expect(SessionTokenHelper.isTokenExpired(pastExp, now), isTrue);
      expect(SessionTokenHelper.minutesUntilExpiration(futureExp, now), 60);
    });

    test('formatBearerHeader prefixes Bearer string when missing', () {
      expect(SessionTokenHelper.formatBearerHeader('xyz123'), 'Bearer xyz123');
      expect(SessionTokenHelper.formatBearerHeader('Bearer xyz123'), 'Bearer xyz123');
    });
  });
}
