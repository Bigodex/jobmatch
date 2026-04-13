// =======================================================
// LANGUAGE MODEL
// -------------------------------------------------------
// Idiomas do usuário
// - fromMap
// - toMap
// - copyWith
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
      level: (map['level'] is int)
          ? map['level']
          : int.tryParse(map['level']?.toString() ?? '') ?? 0,
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

  LanguageModel copyWith({
    String? name,
    int? level,
    String? flag,
  }) {
    return LanguageModel(
      name: name ?? this.name,
      level: level ?? this.level,
      flag: flag ?? this.flag,
    );
  }
}