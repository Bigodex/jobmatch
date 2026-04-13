// =======================================================
// EDUCATION MODEL
// -------------------------------------------------------
// Formação acadêmica
// - parsing seguro
// - toMap / fromMap
// - copyWith com sentinela para campos anuláveis
// =======================================================

const Object _unset = Object();

class EducationModel {
  final String institution;
  final String course;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? logoUrl;

  EducationModel({
    required this.institution,
    required this.course,
    required this.description,
    required this.startDate,
    this.endDate,
    this.logoUrl,
  });

  factory EducationModel.fromMap(Map<String, dynamic> map) {
    return EducationModel(
      institution: map['institution'] ?? '',
      course: map['course'] ?? '',
      description: map['description'] ?? '',
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'].toString())
          : null,
      logoUrl: map['logoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institution': institution,
      'course': course,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'logoUrl': logoUrl,
    };
  }

  EducationModel copyWith({
    String? institution,
    String? course,
    String? description,
    DateTime? startDate,
    Object? endDate = _unset,
    Object? logoUrl = _unset,
  }) {
    return EducationModel(
      institution: institution ?? this.institution,
      course: course ?? this.course,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      logoUrl: identical(logoUrl, _unset) ? this.logoUrl : logoUrl as String?,
    );
  }
}