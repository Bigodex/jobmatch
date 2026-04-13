// =======================================================
// RESUME MODEL
// -------------------------------------------------------
// Informações do card "Resumo Profissional"
//
// ✔ Campos opcionais
// ✔ Labels dinâmicas
// ✔ copyWith com sentinela para campos anuláveis
// =======================================================

const Object _unset = Object();

class ResumeModel {
  final DateTime? birthDate;
  final String? state;
  final String? city;
  final String? description;
  final ResumeLabels labels;

  ResumeModel({
    this.birthDate,
    this.state,
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
          ? DateTime.tryParse(map['birthDate'].toString())
          : null,
      state: map['state']?.toString(),
      city: map['city']?.toString(),
      description: map['description']?.toString(),
      labels: map['labels'] != null
          ? ResumeLabels.fromMap(Map<String, dynamic>.from(map['labels']))
          : ResumeLabels.defaultLabels(),
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'birthDate': birthDate?.toIso8601String(),
      'state': state,
      'city': city,
      'description': description,
      'labels': labels.toMap(),
    };
  }

  // =======================================================
  // COPY WITH
  // -------------------------------------------------------
  // Permite limpar campos anuláveis com null
  // =======================================================
  ResumeModel copyWith({
    Object? birthDate = _unset,
    Object? state = _unset,
    Object? city = _unset,
    Object? description = _unset,
    ResumeLabels? labels,
  }) {
    return ResumeModel(
      birthDate: identical(birthDate, _unset)
          ? this.birthDate
          : birthDate as DateTime?,
      state: identical(state, _unset) ? this.state : state as String?,
      city: identical(city, _unset) ? this.city : city as String?,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
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
  final String stateLabel;
  final String cityLabel;
  final String descriptionLabel;

  ResumeLabels({
    required this.title,
    required this.birthDateLabel,
    required this.stateLabel,
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
      stateLabel: 'Estado',
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
      stateLabel: map['stateLabel'] ?? 'Estado',
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
      'stateLabel': stateLabel,
      'cityLabel': cityLabel,
      'descriptionLabel': descriptionLabel,
    };
  }

  // =======================================================
  // COPY WITH
  // =======================================================
  ResumeLabels copyWith({
    String? title,
    String? birthDateLabel,
    String? stateLabel,
    String? cityLabel,
    String? descriptionLabel,
  }) {
    return ResumeLabels(
      title: title ?? this.title,
      birthDateLabel: birthDateLabel ?? this.birthDateLabel,
      stateLabel: stateLabel ?? this.stateLabel,
      cityLabel: cityLabel ?? this.cityLabel,
      descriptionLabel: descriptionLabel ?? this.descriptionLabel,
    );
  }
}