// =======================================================
// RESUME MODEL
// -------------------------------------------------------
// Informações do card "Resumo Profissional"
//
// Melhorias:
// - Campos opcionais (evita crash)
// - Suporte a labels (backend-driven UI)
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

  factory ResumeLabels.defaultLabels() {
    return ResumeLabels(
      title: 'Resumo Profissional',
      birthDateLabel: 'Data de Nascimento',
      cityLabel: 'Cidade',
      descriptionLabel: 'Descrição',
    );
  }

  factory ResumeLabels.fromMap(Map<String, dynamic> map) {
    return ResumeLabels(
      title: map['title'] ?? 'Resumo Profissional',
      birthDateLabel: map['birthDateLabel'] ?? 'Data de Nascimento',
      cityLabel: map['cityLabel'] ?? 'Cidade',
      descriptionLabel: map['descriptionLabel'] ?? 'Descrição',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'birthDateLabel': birthDateLabel,
      'cityLabel': cityLabel,
      'descriptionLabel': descriptionLabel,
    };
  }
}