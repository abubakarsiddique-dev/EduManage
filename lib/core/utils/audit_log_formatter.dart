/// Formats and redacts administrative audit trails for compliance reporting.
class AuditLogFormatter {
  AuditLogFormatter._();

  static const Set<String> _sensitiveKeys = {
    'password', 'token', 'authorization', 'secret', 'creditcard', 'pin', 'apikey'
  };

  /// Redacts sensitive keys within an audit metadata map.
  static Map<String, dynamic> redactSensitive(Map<String, dynamic> metadata) {
    final clean = <String, dynamic>{};
    for (final entry in metadata.entries) {
      final key = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      if (_sensitiveKeys.contains(key)) {
        clean[entry.key] = '***REDACTED***';
      } else if (entry.value is Map<String, dynamic>) {
        clean[entry.key] = redactSensitive(entry.value as Map<String, dynamic>);
      } else {
        clean[entry.key] = entry.value;
      }
    }
    return clean;
  }

  /// Formats an audit event summary string.
  static String formatEntry({
    required String action,
    required String actorEmail,
    required String targetResource,
    required DateTime timestamp,
  }) {
    final dateStr = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    return '[$dateStr $timeStr] $actorEmail performed $action on $targetResource';
  }
}
