/// Helper for parsing, inspecting, and validating JWT session tokens on the client.
class SessionTokenHelper {
  SessionTokenHelper._();

  /// Estimates whether a JWT bearer token is expired based on unix epoch in seconds.
  static bool isTokenExpired(int expTimestampSeconds, [DateTime? asOfDate]) {
    final nowSeconds = ((asOfDate ?? DateTime.now()).millisecondsSinceEpoch / 1000).floor();
    return nowSeconds >= expTimestampSeconds;
  }

  /// Calculates remaining minutes until token expiration.
  static int minutesUntilExpiration(int expTimestampSeconds, [DateTime? asOfDate]) {
    final nowSeconds = ((asOfDate ?? DateTime.now()).millisecondsSinceEpoch / 1000).floor();
    final remainingSeconds = expTimestampSeconds - nowSeconds;
    if (remainingSeconds <= 0) return 0;
    return (remainingSeconds / 60).floor();
  }

  /// Formats authorization Bearer header.
  static String formatBearerHeader(String token) {
    if (token.startsWith('Bearer ')) return token;
    return 'Bearer $token';
  }
}
