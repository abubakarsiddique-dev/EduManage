import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/inventory_asset_model.dart';

void main() {
  group('InventoryAssetModel Tests', () {
    test('calculateDepreciatedValue estimates salvage value correctly', () {
      final purchaseDate = DateTime(2024, 1, 1);
      final asOfDate = DateTime(2026, 1, 1); // 2 years later
      final asset = InventoryAssetModel(
        id: 'ast1',
        assetTag: 'LAB-PRJ-01',
        name: '4K Classroom Projector',
        category: 'IT Hardware',
        location: 'Hall A',
        purchaseCost: 100000,
        purchaseDate: purchaseDate,
      );

      final val = asset.calculateDepreciatedValue(asOfDate);
      expect(val, lessThan(100000));
      expect(val, greaterThan(50000));
    });

    test('serialization roundtrip preserves asset tag and condition', () {
      final map = {
        'assetTag': 'SCI-MIC-10',
        'name': 'Compound Optical Microscope',
        'category': 'Laboratory',
        'location': 'Bio Lab',
        'purchaseCost': 45000,
        'purchaseDate': DateTime(2025, 6, 1).toIso8601String(),
        'condition': 'needs_repair',
        'isInUse': true,
      };

      final model = InventoryAssetModel.fromMap('ast10', map);
      expect(model.condition, AssetCondition.needsRepair);
      expect(model.assetTag, 'SCI-MIC-10');
      expect(model.toMap()['condition'], 'needs_repair');
    });
  });
}
