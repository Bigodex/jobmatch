// =======================================================
// VALIDATORS
// =======================================================

import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';

class AppValidators {

  // ===================================================
  // REGEX BASE
  // ===================================================
  static final RegExp _textRegex = RegExp(
    r"^[a-zA-ZÀ-ÿ0-9\s\.,\-]+$",
  );

  // ===================================================
  // RESUMO
  // ===================================================
  static String? validateDescription(String value) {
    if (value.trim().isEmpty) return 'O resumo não pode estar vazio';
    if (value.length < 10) return 'Mínimo de 10 caracteres';
    if (value.length > 500) return 'Máximo de 500 caracteres';
    if (!_textRegex.hasMatch(value)) {
      return 'Use apenas letras e pontuação válida';
    }
    return null;
  }

  // ===================================================
  // CIDADE
  // ===================================================
  static String? validateCity(String value) {
    if (value.trim().isEmpty) return 'A cidade é obrigatória';
    if (value.length < 2) return 'Cidade inválida';
    if (value.length > 60) return 'Nome muito longo';
    if (!_textRegex.hasMatch(value)) {
      return 'Use apenas letras válidas';
    }
    return null;
  }

  // ===================================================
  // DATA
  // ===================================================
  static String? validateBirthDate(DateTime? date) {
    if (date == null) return 'Selecione a data';

    final today = DateTime.now();
    if (date.isAfter(today)) return 'Data inválida';

    final age = today.year - date.year;

    if (age < 14) return 'Mínimo 14 anos';
    if (age > 100) return 'Data inválida';

    return null;
  }

  // ===================================================
  // RESUME CHANGE
  // ===================================================
  static bool hasResumeChanged({
    required String originalCity,
    required String newCity,
    required String originalDescription,
    required String newDescription,
    required DateTime? originalBirth,
    required DateTime? newBirth,
  }) {
    return originalCity != newCity ||
        originalDescription != newDescription ||
        originalBirth != newBirth;
  }

  // ===================================================
  // ================== IDIOMAS =========================
  // ===================================================

  static String? validateLanguages(List<LanguageModel> list) {
    if (list.isEmpty) return 'Adicione pelo menos um idioma';
    return null;
  }

  static String? validateDuplicateLanguages(List<LanguageModel> list) {
    final names = list.map((e) => e.name).toList();
    if (names.length != names.toSet().length) {
      return 'Idiomas duplicados';
    }
    return null;
  }

  static String? validateLanguageLevel(int level) {
    if (level < 0 || level > 100) return 'Nível inválido';
    if (level < 10) return 'Nível muito baixo';
    return null;
  }

  static String? validateLanguagesFull(List<LanguageModel> list) {
    final e1 = validateLanguages(list);
    if (e1 != null) return e1;

    final e2 = validateDuplicateLanguages(list);
    if (e2 != null) return e2;

    for (final l in list) {
      final e = validateLanguageLevel(l.level);
      if (e != null) return '${l.name}: $e';
    }

    return null;
  }

  static bool hasLanguagesChanged(
    List<LanguageModel> original,
    List<LanguageModel> edited,
  ) {
    if (original.length != edited.length) return true;

    for (int i = 0; i < original.length; i++) {
      if (original[i].name != edited[i].name ||
          original[i].level != edited[i].level) {
        return true;
      }
    }

    return false;
  }

  // ===================================================
  // ================= SOFT SKILLS ======================
  // ===================================================

  static String? validateSkillTitle(String value) {
    if (value.trim().isEmpty) return 'Título obrigatório';
    if (value.length < 2) return 'Muito curto';
    if (value.length > 40) return 'Muito longo';
    if (!_textRegex.hasMatch(value)) return 'Caracteres inválidos';
    return null;
  }

  static String? validateSkillDescription(String value) {
    if (value.trim().isEmpty) return 'Descrição obrigatória';
    if (value.length < 5) return 'Muito curta';
    if (value.length > 200) return 'Muito longa';
    if (!_textRegex.hasMatch(value)) return 'Caracteres inválidos';
    return null;
  }

  static String? validateSoftSkills(List<SoftSkillModel> list) {
    if (list.isEmpty) return 'Adicione ao menos uma habilidade';

    final names = list.map((e) => e.title).toList();
    if (names.length != names.toSet().length) {
      return 'Habilidades duplicadas';
    }

    for (final s in list) {
      final t = validateSkillTitle(s.title);
      if (t != null) return '${s.title}: $t';

      final d = validateSkillDescription(s.description);
      if (d != null) return '${s.title}: $d';
    }

    return null;
  }

  static bool hasSoftSkillsChanged(
    List<SoftSkillModel> original,
    List<SoftSkillModel> edited,
  ) {
    if (original.length != edited.length) return true;

    for (int i = 0; i < original.length; i++) {
      if (original[i].title != edited[i].title ||
          original[i].description != edited[i].description) {
        return true;
      }
    }

    return false;
  }
}