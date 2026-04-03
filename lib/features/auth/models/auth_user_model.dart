// =======================================================
// AUTH USER MODEL
// -------------------------------------------------------
// Representa o usuário autenticado (Firebase)
// Usado em login, cadastro e sessão
// =======================================================
import 'package:firebase_auth/firebase_auth.dart';

class AuthUserModel {
  final String uid;
  final String email;
  final bool emailVerified;

  const AuthUserModel({
    required this.uid,
    required this.email,
    required this.emailVerified,
  });

  // =======================================================
  // FROM FIREBASE USER
  // -------------------------------------------------------
  // Converte User do FirebaseAuth para nosso model
  // =======================================================
  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(
      uid: user.uid,
      email: user.email ?? '',
      emailVerified: user.emailVerified,
    );
  }

  // =======================================================
  // FROM MAP
  // -------------------------------------------------------
  // Útil caso queira cache/local storage no futuro
  // =======================================================
  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
    );
  }

  // =======================================================
  // TO MAP
  // =======================================================
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'emailVerified': emailVerified,
    };
  }

  // =======================================================
  // COPY WITH
  // =======================================================
  AuthUserModel copyWith({
    String? uid,
    String? email,
    bool? emailVerified,
  }) {
    return AuthUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  String toString() {
    return 'AuthUserModel(uid: $uid, email: $email, emailVerified: $emailVerified)';
  }
}