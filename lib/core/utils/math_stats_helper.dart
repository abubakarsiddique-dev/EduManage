import 'dart:math' as math;

/// Statistical utilities for student score analysis, class averages, and percentiles.
class MathStatsHelper {
  MathStatsHelper._();

  /// Computes the arithmetic mean of a dataset.
  static double mean(List<num> values) {
    if (values.isEmpty) return 0.0;
    final total = values.fold<double>(0.0, (acc, val) => acc + val.toDouble());
    return double.parse((total / values.length).toStringAsFixed(2));
  }

  /// Calculates the median value of a dataset.
  static double median(List<num> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<num>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle].toDouble();
    } else {
      return double.parse(((sorted[middle - 1] + sorted[middle]) / 2.0).toStringAsFixed(2));
    }
  }

  /// Computes the sample standard deviation.
  static double standardDeviation(List<num> values) {
    if (values.length <= 1) return 0.0;
    final avg = mean(values);
    final varianceSum = values.fold<double>(
      0.0,
      (sum, val) => sum + math.pow(val - avg, 2),
    );
    final variance = varianceSum / (values.length - 1);
    return double.parse(math.sqrt(variance).toStringAsFixed(2));
  }

  /// Computes the value at a specified percentile (0 to 100).
  static double percentile(List<num> values, double p) {
    if (values.isEmpty) return 0.0;
    if (p <= 0) return values.reduce(math.min).toDouble();
    if (p >= 100) return values.reduce(math.max).toDouble();

    final sorted = List<num>.from(values)..sort();
    final index = (p / 100) * (sorted.length - 1);
    final lower = index.floor();
    final upper = index.ceil();
    if (lower == upper) return sorted[lower].toDouble();
    final weight = index - lower;
    return double.parse((sorted[lower] * (1 - weight) + sorted[upper] * weight).toStringAsFixed(2));
  }
}
