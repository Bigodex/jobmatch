// =======================================================
// CHAT USER PREVIEW MODEL
// -------------------------------------------------------
// Dados resumidos do participante para chat
// =======================================================

class ChatUserPreviewModel {
  final String uid;
  final String name;
  final String role;
  final String avatarUrl;
  final String email;

  const ChatUserPreviewModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.email,
  });

  // =====================================================
  // FROM MAP
  // =====================================================
  factory ChatUserPreviewModel.fromMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return ChatUserPreviewModel(
      uid: uid,
      name: (map['name'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
      avatarUrl: (map['avatarUrl'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }

  // =====================================================
  // TO MAP
  // =====================================================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }

  // =====================================================
  // COPY WITH
  // =====================================================
  ChatUserPreviewModel copyWith({
    String? uid,
    String? name,
    String? role,
    String? avatarUrl,
    String? email,
  }) {
    return ChatUserPreviewModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
    );
  }
}