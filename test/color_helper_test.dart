import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/color_helper.dart';

void main() {
  group('ColorHelper Tests', () {
    test('fromHex parses 6-char hex with or without hash', () {
      expect(ColorHelper.fromHex('#FFFFFF'), const Color(0xFFFFFFFF));
      expect(ColorHelper.fromHex('000000'), const Color(0xFF000000));
    });

    test('toHex formats color accurately', () {
      expect(ColorHelper.toHex(const Color(0xFF1E88E5)), '#1E88E5');
      expect(ColorHelper.toHex(const Color(0xFF1E88E5), leadingHashSign: false), '1E88E5');
    });

    test('isLight determines perceived lightness', () {
      expect(ColorHelper.isLight(Colors.white), isTrue);
      expect(ColorHelper.isLight(Colors.black), isFalse);
    });
  });
}
