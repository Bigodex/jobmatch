// =======================================================
// USER DOCUMENT MODEL (PADRÃO ISO STRING)
// =======================================================

class UserDocumentModel {
  final String cpf;
  final DateTime? birthDate;

  UserDocumentModel({
    required this.cpf,
    this.birthDate,
  });

  // =======================================================
  // FROM MAP
  // =======================================================
  factory UserDocumentModel.fromMap(Map<String, dynamic> map) {
    return UserDocumentModel(
      cpf: map['cpf'] ?? '',
      birthDate: map['birthDate'] != null
          ? DateTime.tryParse(map['birthDate'])
          : null,
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'cpf': cpf,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  // =======================================================
  // COPY WITH
  // =======================================================
  UserDocumentModel copyWith({
    String? cpf,
    DateTime? birthDate,
  }) {
    return UserDocumentModel(
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}