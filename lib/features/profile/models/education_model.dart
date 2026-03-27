// =======================================================
// EDUCATION MODEL
// =======================================================

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
          ? DateTime.tryParse(map['startDate']) ?? DateTime.now()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'])
          : null,
      logoUrl: map['logoUrl'],
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
    DateTime? endDate,
    String? logoUrl,
  }) {
    return EducationModel(
      institution: institution ?? this.institution,
      course: course ?? this.course,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}