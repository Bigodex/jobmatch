// =======================================================
// USER MODEL
// -------------------------------------------------------
// Dados principais do usuário (header do perfil)
// =======================================================

class UserModel {
  final String name;
  final String email;
  final String role;
  final String avatarUrl;
  final String coverUrl;
  final int connections;
  final int views;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.coverUrl,
    required this.connections,
    required this.views,
  });

  // =======================================================
  // FROM MAP
  // =======================================================
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      connections: map['connections'] ?? 0,
      views: map['views'] ?? 0,
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'connections': connections,
      'views': views,
    };
  }

  // =======================================================
  // COPY WITH (ESSENCIAL PARA ATUALIZAÇÃO DE ESTADO)
  // =======================================================
  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    String? coverUrl,
    int? connections,
    int? views,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      connections: connections ?? this.connections,
      views: views ?? this.views,
    );
  }
}