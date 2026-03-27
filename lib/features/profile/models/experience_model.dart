// =======================================================
// EXPERIENCE MODEL
// -------------------------------------------------------
// Experiências profissionais
//
// Inclui:
// - logo da empresa (logoUrl)
// - parsing seguro
// - estrutura pronta para backend (Firestore/API)
// =======================================================

class ExperienceModel {
  final String company;
  final String role;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? logoUrl;

  ExperienceModel({
    required this.company,
    required this.role,
    required this.description,
    required this.startDate,
    this.endDate,
    this.logoUrl,
  });

  // =======================================================
  // FROM MAP (seguro contra null / erro de parse)
  // =======================================================

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      company: map['company'] ?? '',
      role: map['role'] ?? '',
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

  // =======================================================
  // TO MAP (pronto para salvar no banco)
  // =======================================================

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'role': role,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'logoUrl': logoUrl,
    };
  }

  // =======================================================
  // COPY WITH (útil pra updates)
  // =======================================================

  ExperienceModel copyWith({
    String? company,
    String? role,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? logoUrl,
  }) {
    return ExperienceModel(
      company: company ?? this.company,
      role: role ?? this.role,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}