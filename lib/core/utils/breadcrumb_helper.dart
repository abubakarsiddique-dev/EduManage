/// Represents a single step in a navigation breadcrumb trail.
class BreadcrumbItem {
  final String label;
  final String route;

  const BreadcrumbItem({required this.label, required this.route});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreadcrumbItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          route == other.route;

  @override
  int get hashCode => label.hashCode ^ route.hashCode;
}

/// Helper for parsing URL/route paths into hierarchical breadcrumb items.
class BreadcrumbHelper {
  BreadcrumbHelper._();

  /// Converts a route path (e.g. "/admin/classes/10-A") into a list of [BreadcrumbItem].
  static List<BreadcrumbItem> parseRoute(String routePath) {
    if (routePath.isEmpty || routePath == '/') {
      return const [BreadcrumbItem(label: 'Home', route: '/')];
    }

    final segments = routePath.split('/').where((s) => s.isNotEmpty).toList();
    final items = <BreadcrumbItem>[
      const BreadcrumbItem(label: 'Home', route: '/'),
    ];

    var currentPath = '';
    for (final seg in segments) {
      currentPath += '/$seg';
      final formattedLabel = seg
          .replaceAll('_', ' ')
          .replaceAll('-', ' ')
          .split(' ')
          .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
          .join(' ');
      items.add(BreadcrumbItem(label: formattedLabel, route: currentPath));
    }

    return items;
  }
}
