// =======================================================
// SOFT SKILL MODEL
// -------------------------------------------------------
// Habilidades comportamentais
// =======================================================

class SoftSkillModel {
  final String title;
  final String description;

  SoftSkillModel({
    required this.title,
    required this.description,
  });

  factory SoftSkillModel.fromMap(Map<String, dynamic> map) {
    return SoftSkillModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }
}