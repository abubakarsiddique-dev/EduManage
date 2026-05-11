import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/math_stats_helper.dart';

void main() {
  group('MathStatsHelper Tests', () {
    test('mean calculates accurate average', () {
      expect(MathStatsHelper.mean([10, 20, 30]), 20.0);
      expect(MathStatsHelper.mean([]), 0.0);
    });

    test('median resolves odd and even distributions', () {
      expect(MathStatsHelper.median([10, 20, 30]), 20.0);
      expect(MathStatsHelper.median([10, 20, 30, 40]), 25.0);
    });

    test('standardDeviation computes sample variance correctly', () {
      final scores = [80, 85, 90, 95];
      final sd = MathStatsHelper.standardDeviation(scores);
      expect(sd, greaterThan(6.0));
      expect(sd, lessThan(7.0));
    });

    test('percentile handles boundary and interpolated points', () {
      final scores = [50, 60, 70, 80, 90, 100];
      expect(MathStatsHelper.percentile(scores, 0), 50.0);
      expect(MathStatsHelper.percentile(scores, 100), 100.0);
      expect(MathStatsHelper.percentile(scores, 50), 75.0);
    });
  });
}
