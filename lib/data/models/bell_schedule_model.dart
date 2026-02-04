/// Represents a structured class period or recess slot in the school bell schedule.
class BellScheduleModel {
  final String id;
  final String periodName; // 'Period 1', 'Morning Break', 'Lunch'
  final int periodNumber;
  final String startTime; // '08:00' (24-hour format)
  final String endTime;   // '08:45'
  final bool isRecess;

  const BellScheduleModel({
    required this.id,
    required this.periodName,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
    this.isRecess = false,
  });

  factory BellScheduleModel.fromMap(String id, Map<String, dynamic> map) {
    return BellScheduleModel(
      id: id,
      periodName: map['periodName'] as String? ?? '',
      periodNumber: (map['periodNumber'] as num?)?.toInt() ?? 1,
      startTime: map['startTime'] as String? ?? '08:00',
      endTime: map['endTime'] as String? ?? '08:45',
      isRecess: map['isRecess'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'periodName': periodName,
      'periodNumber': periodNumber,
      'startTime': startTime,
      'endTime': endTime,
      'isRecess': isRecess,
    };
  }

  /// Calculates period duration in minutes.
  int get durationMinutes {
    try {
      final startParts = startTime.split(':').map(int.parse).toList();
      final endParts = endTime.split(':').map(int.parse).toList();
      final startMin = startParts[0] * 60 + startParts[1];
      final endMin = endParts[0] * 60 + endParts[1];
      return endMin - startMin;
    } catch (_) {
      return 45;
    }
  }

  BellScheduleModel copyWith({
    String? id,
    String? periodName,
    int? periodNumber,
    String? startTime,
    String? endTime,
    bool? isRecess,
  }) {
    return BellScheduleModel(
      id: id ?? this.id,
      periodName: periodName ?? this.periodName,
      periodNumber: periodNumber ?? this.periodNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isRecess: isRecess ?? this.isRecess,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BellScheduleModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          periodNumber == other.periodNumber &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => id.hashCode ^ periodNumber.hashCode ^ startTime.hashCode ^ endTime.hashCode;

  @override
  String toString() => 'BellScheduleModel(p$periodNumber: $periodName [$startTime - $endTime])';
}
