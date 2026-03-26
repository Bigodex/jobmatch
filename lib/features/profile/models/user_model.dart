// =======================================================
// USER MODEL
// -------------------------------------------------------
// Dados principais do usuário (header do perfil)
// =======================================================

class UserModel {
  final String name;
  final String role;
  final String avatarUrl;
  final String coverUrl;
  final int connections;
  final int views;

  UserModel({
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.coverUrl,
    required this.connections,
    required this.views,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      connections: map['connections'] ?? 0,
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
      'coverUrl': coverUrl,
      'connections': connections,
      'views': views,
    };
  }
}