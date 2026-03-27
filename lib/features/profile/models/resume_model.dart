// =======================================================
// RESUME MODEL
// -------------------------------------------------------
// Informações do card "Resumo Profissional"
//
// ✔ Campos opcionais
// ✔ Labels dinâmicas
// ✔ copyWith correto (🔥 importante)
// =======================================================

class ResumeModel {
  final DateTime? birthDate;
  final String? city;
  final String? description;

  final ResumeLabels labels;

  ResumeModel({
    this.birthDate,
    this.city,
    this.description,
    required this.labels,
  });

  // =======================================================
  // FROM MAP
  // =======================================================
  factory ResumeModel.fromMap(Map<String, dynamic> map) {
    return ResumeModel(
      birthDate: map['birthDate'] != null
          ? DateTime.tryParse(map['birthDate'])
          : null,
      city: map['city'],
      description: map['description'],
      labels: map['labels'] != null
          ? ResumeLabels.fromMap(map['labels'])
          : ResumeLabels.defaultLabels(),
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'birthDate': birthDate?.toIso8601String(),
      'city': city,
      'description': description,
      'labels': labels.toMap(),
    };
  }

  // =======================================================
  // COPY WITH (🔥 ESSENCIAL)
  // =======================================================
  ResumeModel copyWith({
    DateTime? birthDate,
    String? city,
    String? description,
    ResumeLabels? labels,
  }) {
    return ResumeModel(
      birthDate: birthDate ?? this.birthDate,
      city: city ?? this.city,
      description: description ?? this.description,
      labels: labels ?? this.labels,
    );
  }
}

// =======================================================
// RESUME LABELS
// -------------------------------------------------------
// Textos da UI vindos do backend
// =======================================================

class ResumeLabels {
  final String title;
  final String birthDateLabel;
  final String cityLabel;
  final String descriptionLabel;

  ResumeLabels({
    required this.title,
    required this.birthDateLabel,
    required this.cityLabel,
    required this.descriptionLabel,
  });

  // =======================================================
  // DEFAULT
  // =======================================================
  factory ResumeLabels.defaultLabels() {
    return ResumeLabels(
      title: 'Resumo Profissional',
      birthDateLabel: 'Data de Nascimento',
      cityLabel: 'Cidade',
      descriptionLabel: 'Descrição',
    );
  }

  // =======================================================
  // FROM MAP
  // =======================================================
  factory ResumeLabels.fromMap(Map<String, dynamic> map) {
    return ResumeLabels(
      title: map['title'] ?? 'Resumo Profissional',
      birthDateLabel: map['birthDateLabel'] ?? 'Data de Nascimento',
      cityLabel: map['cityLabel'] ?? 'Cidade',
      descriptionLabel: map['descriptionLabel'] ?? 'Descrição',
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'birthDateLabel': birthDateLabel,
      'cityLabel': cityLabel,
      'descriptionLabel': descriptionLabel,
    };
  }

  // =======================================================
  // COPY WITH (opcional mas útil)
  // =======================================================
  ResumeLabels copyWith({
    String? title,
    String? birthDateLabel,
    String? cityLabel,
    String? descriptionLabel,
  }) {
    return ResumeLabels(
      title: title ?? this.title,
      birthDateLabel: birthDateLabel ?? this.birthDateLabel,
      cityLabel: cityLabel ?? this.cityLabel,
      descriptionLabel: descriptionLabel ?? this.descriptionLabel,
    );
  }
}