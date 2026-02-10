import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/number_format_helper.dart';

void main() {
  group('NumberFormatHelper Tests', () {
    test('toOrdinal formats special and regular numbers', () {
      expect(NumberFormatHelper.toOrdinal(1), '1st');
      expect(NumberFormatHelper.toOrdinal(2), '2nd');
      expect(NumberFormatHelper.toOrdinal(3), '3rd');
      expect(NumberFormatHelper.toOrdinal(4), '4th');
      expect(NumberFormatHelper.toOrdinal(11), '11th');
      expect(NumberFormatHelper.toOrdinal(12), '12th');
      expect(NumberFormatHelper.toOrdinal(13), '13th');
      expect(NumberFormatHelper.toOrdinal(21), '21st');
      expect(NumberFormatHelper.toOrdinal(22), '22nd');
    });

    test('toCompact handles thousands and millions', () {
      expect(NumberFormatHelper.toCompact(950), '950');
      expect(NumberFormatHelper.toCompact(1000), '1K');
      expect(NumberFormatHelper.toCompact(2500), '2.5K');
      expect(NumberFormatHelper.toCompact(1000000), '1M');
      expect(NumberFormatHelper.toCompact(3200000), '3.2M');
    });
  });
}
