/// Standardized system error codes and human-friendly localized descriptions.
class AppErrorCodes {
  AppErrorCodes._();

  static const String authInvalidEmail = 'AUTH_INVALID_EMAIL';
  static const String authWrongPassword = 'AUTH_WRONG_PASSWORD';
  static const String authUserNotFound = 'AUTH_USER_NOT_FOUND';
  static const String authUserDisabled = 'AUTH_USER_DISABLED';
  static const String authSessionExpired = 'AUTH_SESSION_EXPIRED';

  static const String netNoInternet = 'NET_NO_INTERNET';
  static const String netTimeout = 'NET_TIMEOUT';
  static const String netServerError = 'NET_SERVER_ERROR';

  static const String dbPermissionDenied = 'DB_PERMISSION_DENIED';
  static const String dbNotFound = 'DB_NOT_FOUND';
  static const String dbAlreadyExists = 'DB_ALREADY_EXISTS';

  static const String validationFailed = 'VALIDATION_FAILED';
  static const String unknown = 'UNKNOWN_ERROR';

  static const Map<String, String> _messages = {
    authInvalidEmail: 'Please enter a valid email address.',
    authWrongPassword: 'The password entered is incorrect.',
    authUserNotFound: 'No user account found matching this identifier.',
    authUserDisabled: 'This account has been disabled. Please contact administration.',
    authSessionExpired: 'Your login session has expired. Please log in again.',
    netNoInternet: 'No internet connection detected. Please verify your network.',
    netTimeout: 'The request timed out. Please try again in a few moments.',
    netServerError: 'Internal server error occurred. Please contact support.',
    dbPermissionDenied: 'You do not have administrative clearance for this operation.',
    dbNotFound: 'The requested resource was not located.',
    dbAlreadyExists: 'A record with these credentials already exists.',
    validationFailed: 'Please review and correct form errors before submitting.',
  };

  /// Returns a user-friendly error description for the given code.
  static String getMessage(String? code, [String fallback = 'An unexpected error occurred. Please try again.']) {
    if (code == null || code.isEmpty) return fallback;
    return _messages[code] ?? fallback;
  }
}
