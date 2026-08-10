// lib/data/repositories/local_auth_repository.dart

import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';

/// Internal-only record pairing a mock UserModel with login credentials.
/// Kept private to this file so UserModel stays a clean domain model with
/// no auth-specific fields on it.
class _Account {
  final UserModel user;
  final String username;
  final String password;

  _Account({
    required this.user,
    required this.username,
    required this.password,
  });
}

/// Mock in-memory auth repository. Simulates network latency and basic
/// validation so the UI can be built end-to-end before Firebase is wired in.
class LocalAuthRepository implements IAuthRepository {
  // Seeded mock account so login() has something to authenticate against.
  final List<_Account> _accounts = [
    _Account(
      user: const UserModel(
        id: 'user_001',
        fullName: 'Ali Khan',
        email: 'ali.khan@gmail.com',
        phone: '03001234567',
        role: 'owner',
      ),
      username: 'alikhan',
      password: 'Password123',
    ),
  ];

  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 700));

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    await _simulateLatency();

    final match = _accounts.where(
      (a) =>
          (a.username == username || a.user.email == username) &&
          a.password == password,
    );

    if (match.isEmpty) {
      throw Exception('Incorrect username or password');
    }

    _currentUser = match.first.user;
    return _currentUser!;
  }

  @override
  Future<AuthResult> loginWithGoogle() async {
    await _simulateLatency();
    return _oauthSignIn(
      email: 'google.user@gmail.com',
      fullName: 'Google User',
      idPrefix: 'user_google',
    );
  }

  @override
  Future<AuthResult> loginWithApple() async {
    await _simulateLatency();
    return _oauthSignIn(
      email: 'apple.user@icloud.com',
      fullName: 'Apple User',
      idPrefix: 'user_apple',
    );
  }

  Future<AuthResult> _oauthSignIn({
    required String email,
    required String fullName,
    required String idPrefix,
  }) async {
    final existing = _accounts.where((a) => a.user.email == email);

    if (existing.isNotEmpty) {
      _currentUser = existing.first.user;
      return AuthResult(user: _currentUser!, isNewUser: false);
    }

    // role is left empty — role_selection screen fills it in post-signup.
    final newUser = UserModel(
      id: '${idPrefix}_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: '',
      role: '',
    );

    _accounts.add(_Account(user: newUser, username: email, password: ''));
    _currentUser = newUser;
    return AuthResult(user: newUser, isNewUser: true);
  }

  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _simulateLatency();

    final alreadyExists = _accounts.any((a) => a.user.email == email);
    if (alreadyExists) {
      throw Exception('An account with this email already exists');
    }

    // role is left empty — role_selection screen fills it in post-signup.
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: phone,
      role: '',
    );

    _accounts.add(_Account(user: newUser, username: email, password: password));
    _currentUser = newUser;
    return newUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _simulateLatency();

    final exists = _accounts.any((a) => a.user.email == email);
    if (!exists) {
      throw Exception('No account found for $email');
    }
    // No real email is sent locally — this just simulates success.
  }
   @override
  Future<UserModel> updateUserRole(String role) async {
    await _simulateLatency();

    final user = _currentUser;
    if (user == null) {
      throw Exception('No signed-in user to update');
    }

    final updatedUser = user.copyWith(role: role);

    final index = _accounts.indexWhere((a) => a.user.id == user.id);
    if (index != -1) {
      _accounts[index] = _Account(
        user: updatedUser,
        username: _accounts[index].username,
        password: _accounts[index].password,
      );
    }

    _currentUser = updatedUser;
    return updatedUser;
  }

  @override
  Future<void> logout() async {
    await _simulateLatency();
    _currentUser = null;
  }
}