import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/constants/app_asset_paths.dart';

void main() {
  group('AppAssetPaths Tests', () {
    test('static constants have correct directory prefixes', () {
      expect(AppAssetPaths.logo.startsWith(AppAssetPaths.baseImages), isTrue);
      expect(AppAssetPaths.dashboardIcon.startsWith(AppAssetPaths.baseIcons), isTrue);
      expect(AppAssetPaths.busIcon.startsWith(AppAssetPaths.baseIcons), isTrue);
    });

    test('extension helpers identify svg and png paths', () {
      expect(AppAssetPaths.isSvg('assets/icons/home.svg'), isTrue);
      expect(AppAssetPaths.isSvg('assets/images/logo.png'), isFalse);
      expect(AppAssetPaths.isPng('assets/images/logo.png'), isTrue);
      expect(AppAssetPaths.isPng('assets/icons/home.svg'), isFalse);
    });
  });
}
