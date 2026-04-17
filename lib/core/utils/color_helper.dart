import 'package:flutter/material.dart';

/// Utilities for parsing, formatting, and analyzing UI colors.
class ColorHelper {
  ColorHelper._();

  /// Converts a hex string (e.g. "#FFFFFF" or "FFFFFF" or "FFFFFFFF") to a [Color].
  static Color fromHex(String hexString, [Color fallback = Colors.transparent]) {
    try {
      final buffer = StringBuffer();
      final clean = hexString.replaceAll('#', '').trim();
      if (clean.length == 6) {
        buffer.write('ff');
        buffer.write(clean);
      } else if (clean.length == 8) {
        buffer.write(clean);
      } else {
        return fallback;
      }
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  /// Converts a [Color] to an uppercase 6-digit hex string (e.g. "#1A2B3C").
  static String toHex(Color color, {bool leadingHashSign = true}) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    final prefix = leadingHashSign ? '#' : '';
    return '$prefix$r$g$b'.toUpperCase();
  }

  /// Calculates relative luminance and determines if color is light.
  static bool isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }
}
