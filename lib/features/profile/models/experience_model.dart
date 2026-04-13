// =======================================================
// EXPERIENCE MODEL
// -------------------------------------------------------
// Experiências profissionais
// - parsing seguro
// - toMap / fromMap
// - copyWith com sentinela para campos anuláveis
// =======================================================

const Object _unset = Object();

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
  // FROM MAP
  // =======================================================
  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      company: map['company'] ?? '',
      role: map['role'] ?? '',
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

  // =======================================================
  // TO MAP
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
  // COPY WITH
  // -------------------------------------------------------
  // Permite limpar campos anuláveis com null
  // =======================================================
  ExperienceModel copyWith({
    String? company,
    String? role,
    String? description,
    DateTime? startDate,
    Object? endDate = _unset,
    Object? logoUrl = _unset,
  }) {
    return ExperienceModel(
      company: company ?? this.company,
      role: role ?? this.role,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      logoUrl: identical(logoUrl, _unset) ? this.logoUrl : logoUrl as String?,
    );
  }
}