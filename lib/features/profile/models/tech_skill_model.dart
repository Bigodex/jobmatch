// =======================================================
// TECH SKILL MODEL
// -------------------------------------------------------
// Habilidades técnicas (robusto + seguro)
// =======================================================

class TechSkillModel {
  final String title;
  final int level; // 🔥 0 → 100 (recomendado)
  final List<String> tools;

  TechSkillModel({
    required this.title,
    required this.level,
    required this.tools,
  });

  // =======================================================
  // FROM MAP (seguro)
  // =======================================================
  factory TechSkillModel.fromMap(Map<String, dynamic> map) {
    return TechSkillModel(
      title: map['title'] ?? '',

      // 🔥 proteção contra null e tipo errado
      level: (map['level'] is int)
          ? map['level']
          : int.tryParse(map['level']?.toString() ?? '') ?? 0,

      // 🔥 proteção forte para lista
      tools: map['tools'] != null
          ? List<String>.from(map['tools'])
          : [],
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'level': level,
      'tools': tools,
    };
  }

  // =======================================================
  // COPY WITH (ESSENCIAL)
  // =======================================================
  TechSkillModel copyWith({
    String? title,
    int? level,
    List<String>? tools,
  }) {
    return TechSkillModel(
      title: title ?? this.title,
      level: level ?? this.level,
      tools: tools ?? this.tools,
    );
  }
}