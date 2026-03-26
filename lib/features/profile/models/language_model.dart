// =======================================================
// LANGUAGE MODEL
// -------------------------------------------------------
// Idiomas do usuário
// =======================================================

class LanguageModel {
  final String name;
  final int level;
  final String flag;

  LanguageModel({
    required this.name,
    required this.level,
    required this.flag,
  });

  factory LanguageModel.fromMap(Map<String, dynamic> map) {
    return LanguageModel(
      name: map['name'] ?? '',
      level: map['level'] ?? 0,
      flag: map['flag'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'flag': flag,
    };
  }
}