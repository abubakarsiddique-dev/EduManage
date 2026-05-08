import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/app_notification_channels.dart';

void main() {
  group('AppNotificationChannels Tests', () {
    test('predefined channels have associated name and description', () {
      final channels = [
        AppNotificationChannels.academic,
        AppNotificationChannels.attendance,
        AppNotificationChannels.fees,
        AppNotificationChannels.notices,
        AppNotificationChannels.system,
      ];

      for (final ch in channels) {
        expect(AppNotificationChannels.channelNames.containsKey(ch), isTrue);
        expect(AppNotificationChannels.channelDescriptions.containsKey(ch), isTrue);
        expect(AppNotificationChannels.getName(ch).isNotEmpty, isTrue);
      }
    });

    test('getName returns fallback for unknown channel', () {
      expect(
        AppNotificationChannels.getName('unknown_ch', 'Fallback Channel'),
        'Fallback Channel',
      );
    });
  });
}
