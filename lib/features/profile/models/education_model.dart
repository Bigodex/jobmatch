// =======================================================
// EDUCATION MODEL
// -------------------------------------------------------
// Formação acadêmica
// =======================================================

class EducationModel {
  final String institution;
  final String course;
  final DateTime startDate;
  final DateTime? endDate;

  EducationModel({
    required this.institution,
    required this.course,
    required this.startDate,
    this.endDate,
  });

  factory EducationModel.fromMap(Map<String, dynamic> map) {
    return EducationModel(
      institution: map['institution'] ?? '',
      course: map['course'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institution': institution,
      'course': course,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}