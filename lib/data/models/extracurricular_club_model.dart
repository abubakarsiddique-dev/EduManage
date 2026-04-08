/// Represents a student society, club, or sports team on campus.
class ExtracurricularClubModel {
  final String id;
  final String clubName;
  final String category; // 'Sports' | 'Science & Tech' | 'Arts & Culture' | 'Debating'
  final String patronTeacherId;
  final String patronTeacherName;
  final int memberCount;
  final String meetingSchedule;
  final bool isRecruiting;

  const ExtracurricularClubModel({
    required this.id,
    required this.clubName,
    required this.category,
    required this.patronTeacherId,
    required this.patronTeacherName,
    this.memberCount = 0,
    this.meetingSchedule = 'Every Friday 3:00 PM',
    this.isRecruiting = true,
  });

  factory ExtracurricularClubModel.fromMap(String id, Map<String, dynamic> map) {
    return ExtracurricularClubModel(
      id: id,
      clubName: map['clubName'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      patronTeacherId: map['patronTeacherId'] as String? ?? '',
      patronTeacherName: map['patronTeacherName'] as String? ?? '',
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
      meetingSchedule: map['meetingSchedule'] as String? ?? 'Every Friday 3:00 PM',
      isRecruiting: map['isRecruiting'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clubName': clubName,
      'category': category,
      'patronTeacherId': patronTeacherId,
      'patronTeacherName': patronTeacherName,
      'memberCount': memberCount,
      'meetingSchedule': meetingSchedule,
      'isRecruiting': isRecruiting,
    };
  }

  ExtracurricularClubModel copyWith({
    String? id,
    String? clubName,
    String? category,
    String? patronTeacherId,
    String? patronTeacherName,
    int? memberCount,
    String? meetingSchedule,
    bool? isRecruiting,
  }) {
    return ExtracurricularClubModel(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      category: category ?? this.category,
      patronTeacherId: patronTeacherId ?? this.patronTeacherId,
      patronTeacherName: patronTeacherName ?? this.patronTeacherName,
      memberCount: memberCount ?? this.memberCount,
      meetingSchedule: meetingSchedule ?? this.meetingSchedule,
      isRecruiting: isRecruiting ?? this.isRecruiting,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtracurricularClubModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clubName == other.clubName;

  @override
  int get hashCode => id.hashCode ^ clubName.hashCode;

  @override
  String toString() => 'ExtracurricularClubModel(name: $clubName, members: $memberCount)';
}
