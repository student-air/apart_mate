// lib/domain/repositories/i_auth_repository.dart

import 'package:apart_mate/data/models/user_model.dart';

class AuthResult {
  final UserModel user;
  final bool isNewUser;

  const AuthResult({
    required this.user,
    required this.isNewUser,
  });
}

abstract class IAuthRepository {
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

  /// Updates the current user's role (e.g. after role_selection) and
  /// returns the updated user.
  Future<UserModel> updateUserRole(String role);

  Future<void> logout();
}