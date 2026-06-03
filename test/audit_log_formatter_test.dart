import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/audit_log_formatter.dart';

void main() {
  group('AuditLogFormatter Tests', () {
    test('redactSensitive obfuscates password and token fields', () {
      final input = {
        'username': 'admin',
        'password': 'SuperSecretPassword123!',
        'authToken': 'xyz789token',
        'details': {
          'apiKey': 'secret_key_111',
          'role': 'super_admin',
        }
      };

      final sanitized = AuditLogFormatter.redactSensitive(input);
      expect(sanitized['password'], '***REDACTED***');
      expect(sanitized['authToken'], '***REDACTED***');
      expect((sanitized['details'] as Map)['apiKey'], '***REDACTED***');
      expect((sanitized['details'] as Map)['role'], 'super_admin');
    });

    test('formatEntry builds clean log description', () {
      final log = AuditLogFormatter.formatEntry(
        action: 'UPDATE_GRADE',
        actorEmail: 'teacher@school.edu',
        targetResource: 'Result#991',
        timestamp: DateTime(2026, 6, 3, 11, 30),
      );

      expect(log, '[2026-06-03 11:30] teacher@school.edu performed UPDATE_GRADE on Result#991');
    });
  });
}
