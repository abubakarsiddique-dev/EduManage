import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/app_error_codes.dart';

void main() {
  group('AppErrorCodes Tests', () {
    test('getMessage returns correct message for known codes', () {
      expect(
        AppErrorCodes.getMessage(AppErrorCodes.authInvalidEmail),
        'Please enter a valid email address.',
      );
      expect(
        AppErrorCodes.getMessage(AppErrorCodes.netNoInternet),
        'No internet connection detected. Please verify your network.',
      );
    });

    test('getMessage returns fallback for null, empty or unknown codes', () {
      const fallback = 'Custom fallback message.';
      expect(AppErrorCodes.getMessage(null, fallback), fallback);
      expect(AppErrorCodes.getMessage('', fallback), fallback);
      expect(AppErrorCodes.getMessage('NON_EXISTENT_CODE', fallback), fallback);
    });
  });
}
