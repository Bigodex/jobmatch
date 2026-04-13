// =======================================================
// USER DOCUMENT MODEL
// -------------------------------------------------------
// Documento do usuário
// - padrão ISO string
// - fromMap
// - toMap
// - copyWith com sentinela para campos anuláveis
// =======================================================

const Object _unset = Object();

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
          ? DateTime.tryParse(map['birthDate'].toString())
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
    Object? birthDate = _unset,
  }) {
    return UserDocumentModel(
      cpf: cpf ?? this.cpf,
      birthDate: identical(birthDate, _unset)
          ? this.birthDate
          : birthDate as DateTime?,
    );
  }
}