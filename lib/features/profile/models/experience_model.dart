// =======================================================
// EXPERIENCE MODEL
// -------------------------------------------------------
// Experiências profissionais
// =======================================================

class ExperienceModel {
  final String company;
  final String role;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;

  ExperienceModel({
    required this.company,
    required this.role,
    required this.description,
    required this.startDate,
    this.endDate,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      description: map['description'] ?? '',
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'role': role,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}