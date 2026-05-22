import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/breadcrumb_helper.dart';

void main() {
  group('BreadcrumbHelper Tests', () {
    test('parseRoute splits path into hierarchy', () {
      final items = BreadcrumbHelper.parseRoute('/admin/classes/tenth-grade');
      expect(items.length, 4);
      expect(items[0].label, 'Home');
      expect(items[0].route, '/');
      expect(items[1].label, 'Admin');
      expect(items[1].route, '/admin');
      expect(items[2].label, 'Classes');
      expect(items[2].route, '/admin/classes');
      expect(items[3].label, 'Tenth Grade');
      expect(items[3].route, '/admin/classes/tenth-grade');
    });

    test('parseRoute handles root path cleanly', () {
      final items = BreadcrumbHelper.parseRoute('/');
      expect(items.length, 1);
      expect(items.first.label, 'Home');
    });
  });
}
