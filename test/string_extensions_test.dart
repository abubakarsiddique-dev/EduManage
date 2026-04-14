import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/string_extensions.dart';

void main() {
  group('StringExtensions Tests', () {
    test('toCapitalized capitalizes single word', () {
      expect('flutter'.toCapitalized(), 'Flutter');
      expect(''.toCapitalized(), '');
    });

    test('toTitleCase converts sentence to title case', () {
      expect('edumanage student portal'.toTitleCase(), 'Edumanage Student Portal');
    });

    test('initials extracts correct letters', () {
      expect('John Doe'.initials(), 'JD');
      expect('Muhammad Abubakar Siddique'.initials(3), 'MAS');
      expect(''.initials(), '');
    });

    test('maskEmail obfuscates username while preserving domain', () {
      expect('student@school.edu'.maskEmail(), 's*****t@school.edu');
      expect('ab@school.edu'.maskEmail(), 'a*@school.edu');
    });
  });
}
