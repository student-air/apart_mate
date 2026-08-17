// lib/data/repositories/firebase_auth_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  // ── Login (username field = email) ───────────────────────────
  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: username.trim(),
        password: password,
      );
      _currentUser = await _loadProfile(
        uid: cred.user!.uid,
        fallbackEmail: cred.user!.email ?? username.trim(),
      );
      return _currentUser!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_message(e));
    }
  }

  // ── Sign up ──────────────────────────────────────────────────
  @override
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;

      final user = UserModel(
        id: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: '', // role_selection fills later
      );

      await _usersCol.doc(uid).set({
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
        'role': '',
        'photoPath': null,
        'propertyType': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUser = user;
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_message(e));
    }
  }

  // ── Google ───────────────────────────────────────────────────
  @override
  Future<AuthResult> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      final uid = cred.user!.uid;
      final isNew = cred.additionalUserInfo?.isNewUser ?? false;

      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists) {
        await _usersCol.doc(uid).set({
          'fullName': cred.user!.displayName ?? 'User',
          'email': cred.user!.email ?? googleUser.email,
          'phone': cred.user!.phoneNumber ?? '',
          'role': '',
          'photoPath': cred.user!.photoURL,
          'propertyType': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _currentUser = await _loadProfile(
        uid: uid,
        fallbackEmail: cred.user!.email ?? googleUser.email,
        fallbackName: cred.user!.displayName,
      );

      // isNewUser true → onboarding; false → can go dashboard if role set
      return AuthResult(user: _currentUser!, isNewUser: isNew);
    } on FirebaseAuthException catch (e) {
      throw Exception(_message(e));
    }
  }

  // ── Apple (not configured yet) ───────────────────────────────
  @override
  Future<AuthResult> loginWithApple() async {
    throw Exception('Apple sign-in is not configured yet');
  }

  /// Call on splash / app start
Future<UserModel?> restoreSession() async {
  final fbUser = _auth.currentUser;
  if (fbUser == null) {
    _currentUser = null;
    return null;
  }
  _currentUser = await _loadProfile(
    uid: fbUser.uid,
    fallbackEmail: fbUser.email ?? '',
    fallbackName: fbUser.displayName,
  );
  return _currentUser;
}

  // ── Password reset ───────────────────────────────────────────
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_message(e));
    }
  }

  // ── Role (after role_selection) ──────────────────────────────
  @override
  Future<UserModel> updateUserRole(String role) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('No signed-in user to update');
    }

    await _usersCol.doc(user.id).set(
      {'role': role, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    final updated = user.copyWith(role: role);
    _currentUser = updated;
    return updated;
  }

  // ── Profile update (edit profile) ────────────────────────────
  @override
  Future<UserModel> updateCurrentUser(UserModel user) async {
    await _usersCol.doc(user.id).set({
      'fullName': user.fullName,
      'email': user.email,
      'phone': user.phone,
      'role': user.role,
      'photoPath': user.photoPath,
      'propertyType': user.propertyType,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _currentUser = user;
    return user;
  }

  // ── Property type ────────────────────────────────────────────
  @override
  Future<void> updateUserPropertyType(String s) async {
    final user = _currentUser;
    if (user == null) return;

    await _usersCol.doc(user.id).set(
      {'propertyType': s, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    _currentUser = user.copyWith(propertyType: s);
  }

  // ── Logout ───────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    _currentUser = null;
  }

  // ── Helpers ──────────────────────────────────────────────────
  Future<UserModel> _loadProfile({
    required String uid,
    required String fallbackEmail,
    String? fallbackName,
  }) async {
    final doc = await _usersCol.doc(uid).get();
    if (doc.exists) {
      final d = doc.data()!;
      return UserModel(
        id: uid,
        fullName: (d['fullName'] as String?) ?? fallbackName ?? '',
        email: (d['email'] as String?) ?? fallbackEmail,
        phone: (d['phone'] as String?) ?? '',
        role: (d['role'] as String?) ?? '',
        photoPath: d['photoPath'] as String?,
        propertyType: d['propertyType'] as String?,
      );
    }

    final user = UserModel(
      id: uid,
      fullName: fallbackName ?? '',
      email: fallbackEmail,
      phone: '',
      role: '',
    );
    await _usersCol.doc(uid).set({
      'fullName': user.fullName,
      'email': user.email,
      'phone': user.phone,
      'role': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return user;
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect username or password';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}