enum AssetCondition { excellent, good, needsRepair, obsolete }

/// Represents an institutional asset (laboratory apparatus, computer terminal, projector).
class InventoryAssetModel {
  final String id;
  final String assetTag;
  final String name;
  final String category; // 'IT Hardware' | 'Laboratory' | 'Sports' | 'Furniture'
  final String location;
  final double purchaseCost;
  final DateTime purchaseDate;
  final AssetCondition condition;
  final bool isInUse;

  const InventoryAssetModel({
    required this.id,
    required this.assetTag,
    required this.name,
    required this.category,
    required this.location,
    required this.purchaseCost,
    required this.purchaseDate,
    this.condition = AssetCondition.good,
    this.isInUse = true,
  });

  factory InventoryAssetModel.fromMap(String id, Map<String, dynamic> map) {
    AssetCondition parseCondition(String? str) {
      switch (str?.toLowerCase().trim()) {
        case 'excellent':
          return AssetCondition.excellent;
        case 'needs_repair':
        case 'needsrepair':
          return AssetCondition.needsRepair;
        case 'obsolete':
          return AssetCondition.obsolete;
        default:
          return AssetCondition.good;
      }
    }

    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    return InventoryAssetModel(
      id: id,
      assetTag: map['assetTag'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      location: map['location'] as String? ?? '',
      purchaseCost: (map['purchaseCost'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: parseDate(map['purchaseDate']),
      condition: parseCondition(map['condition'] as String?),
      isInUse: map['isInUse'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    String conditionToString(AssetCondition c) {
      switch (c) {
        case AssetCondition.excellent:
          return 'excellent';
        case AssetCondition.needsRepair:
          return 'needs_repair';
        case AssetCondition.obsolete:
          return 'obsolete';
        case AssetCondition.good:
          return 'good';
      }
    }

    return {
      'assetTag': assetTag,
      'name': name,
      'category': category,
      'location': location,
      'purchaseCost': purchaseCost,
      'purchaseDate': purchaseDate.toIso8601String(),
      'condition': conditionToString(condition),
      'isInUse': isInUse,
    };
  }

  /// Calculates depreciated straight-line asset value based on 5-year lifecycle.
  double calculateDepreciatedValue([DateTime? asOfDate]) {
    final now = asOfDate ?? DateTime.now();
    final years = now.difference(purchaseDate).inDays / 365.25;
    if (years <= 0) return purchaseCost;
    if (years >= 5.0) return double.parse((purchaseCost * 0.1).toStringAsFixed(2)); // 10% salvage value
    final depreciated = purchaseCost * (1.0 - (years * 0.18));
    return double.parse(depreciated.clamp(purchaseCost * 0.1, purchaseCost).toStringAsFixed(2));
  }

  InventoryAssetModel copyWith({
    String? id,
    String? assetTag,
    String? name,
    String? category,
    String? location,
    double? purchaseCost,
    DateTime? purchaseDate,
    AssetCondition? condition,
    bool? isInUse,
  }) {
    return InventoryAssetModel(
      id: id ?? this.id,
      assetTag: assetTag ?? this.assetTag,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      condition: condition ?? this.condition,
      isInUse: isInUse ?? this.isInUse,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryAssetModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          assetTag == other.assetTag;

  @override
  int get hashCode => id.hashCode ^ assetTag.hashCode;

  @override
  String toString() => 'InventoryAssetModel(tag: $assetTag, name: $name, location: $location)';
}
