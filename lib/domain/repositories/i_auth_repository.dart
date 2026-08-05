// lib/domain/repositories/i_auth_repository.dart

import 'package:apart_mate/data/models/user_model.dart';

/// Result of an OAuth (Google/Apple) sign-in attempt.
class AuthResult {
  final UserModel user;
  final bool isNewUser;

  const AuthResult({
    required this.user,
    required this.isNewUser,
  });
}

abstract class IAuthRepository {
  /// The currently signed-in user, or null if signed out.
  UserModel? get currentUser;

  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<AuthResult> loginWithGoogle();

  Future<AuthResult> loginWithApple();

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();
}