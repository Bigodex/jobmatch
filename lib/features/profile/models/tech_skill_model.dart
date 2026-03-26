// =======================================================
// TECH SKILL MODEL
// -------------------------------------------------------
// Habilidades técnicas
// =======================================================

class TechSkillModel {
  final String title;
  final int level;
  final List<String> tools;

  TechSkillModel({
    required this.title,
    required this.level,
    required this.tools,
  });

  factory TechSkillModel.fromMap(Map<String, dynamic> map) {
    return TechSkillModel(
      title: map['title'] ?? '',
      level: map['level'] ?? 0,
      tools: List<String>.from(map['tools'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'level': level,
      'tools': tools,
    };
  }
}