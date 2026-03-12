/// Represents a digital certificate of achievement, merit, or course completion.
class CertificateTemplateModel {
  final String id;
  final String title;
  final String certificateType; // 'Academic Merit' | 'Sports Excellence' | 'Participation'
  final String issuerName;
  final String issuerDesignation;
  final String borderStyle;
  final bool hasQrVerification;

  const CertificateTemplateModel({
    required this.id,
    required this.title,
    required this.certificateType,
    required this.issuerName,
    this.issuerDesignation = 'Principal',
    this.borderStyle = 'classic_gold',
    this.hasQrVerification = true,
  });

  factory CertificateTemplateModel.fromMap(String id, Map<String, dynamic> map) {
    return CertificateTemplateModel(
      id: id,
      title: map['title'] as String? ?? '',
      certificateType: map['certificateType'] as String? ?? 'Academic Merit',
      issuerName: map['issuerName'] as String? ?? '',
      issuerDesignation: map['issuerDesignation'] as String? ?? 'Principal',
      borderStyle: map['borderStyle'] as String? ?? 'classic_gold',
      hasQrVerification: map['hasQrVerification'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'certificateType': certificateType,
      'issuerName': issuerName,
      'issuerDesignation': issuerDesignation,
      'borderStyle': borderStyle,
      'hasQrVerification': hasQrVerification,
    };
  }

  CertificateTemplateModel copyWith({
    String? id,
    String? title,
    String? certificateType,
    String? issuerName,
    String? issuerDesignation,
    String? borderStyle,
    bool? hasQrVerification,
  }) {
    return CertificateTemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      certificateType: certificateType ?? this.certificateType,
      issuerName: issuerName ?? this.issuerName,
      issuerDesignation: issuerDesignation ?? this.issuerDesignation,
      borderStyle: borderStyle ?? this.borderStyle,
      hasQrVerification: hasQrVerification ?? this.hasQrVerification,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CertificateTemplateModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          certificateType == other.certificateType;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ certificateType.hashCode;

  @override
  String toString() => 'CertificateTemplateModel(title: $title, type: $certificateType)';
}
