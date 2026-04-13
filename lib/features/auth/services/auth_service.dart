// =======================================================
// AUTH SERVICE
// -------------------------------------------------------
// Responsável por conversar com o Firebase Auth
// =======================================================

import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =====================================================
  // AUTH STATE CHANGES
  // -----------------------------------------------------
  // Escuta mudanças de autenticação em tempo real
  // =====================================================
  Stream<AuthUserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUserModel.fromFirebaseUser(user);
    });
  }

  // =====================================================
  // CURRENT USER
  // -----------------------------------------------------
  // Retorna o usuário autenticado atual
  // =====================================================
  AuthUserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AuthUserModel.fromFirebaseUser(user);
  }

  // =====================================================
  // REGISTER
  // -----------------------------------------------------
  // Cria usuário com email e senha
  // =====================================================
  Future<AuthUserModel> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Usuário não foi criado corretamente.');
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  // =====================================================
  // LOGIN
  // -----------------------------------------------------
  // Faz login com email e senha
  // =====================================================
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Usuário não encontrado após login.');
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  // =====================================================
  // UPDATE CURRENT USER EMAIL
  // -----------------------------------------------------
  // Solicita a alteração do e-mail do usuário autenticado
  // =====================================================
  Future<void> updateCurrentUserEmail(String newEmail) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'Nenhum usuário autenticado.',
      );
    }

    await user.verifyBeforeUpdateEmail(newEmail.trim());
  }

  // =====================================================
  // LOGOUT
  // -----------------------------------------------------
  // Encerra a sessão do usuário
  // =====================================================
  Future<void> logout() async {
    await _auth.signOut();
  }
}