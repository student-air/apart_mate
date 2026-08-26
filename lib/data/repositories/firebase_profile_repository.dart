// lib/data/repositories/firebase_profile_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';

/// Profile extras (gender, city, occupation, emergency) stored on users/{userId}.
class FirebaseProfileRepository implements IProfileRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    if (userId.isEmpty) return null;

    final doc = await _users.doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;

    final d = doc.data()!;
    final gender = (d['gender'] as String?) ?? '';
    final city = (d['city'] as String?) ?? '';
    final occupation = (d['occupation'] as String?) ?? '';
    final emergencyContact = (d['emergencyContact'] as String?) ?? '';

    // No profile-setup data yet
    if (gender.isEmpty &&
        city.isEmpty &&
        occupation.isEmpty &&
        emergencyContact.isEmpty) {
      return null;
    }

    return ProfileModel(
      userId: userId,
      gender: gender,
      city: city,
      occupation: occupation,
      emergencyContact: emergencyContact,
    );
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    if (profile.userId.isEmpty) return;

    await _users.doc(profile.userId).set(
      {
        'gender': profile.gender,
        'city': profile.city,
        'occupation': profile.occupation,
        'emergencyContact': profile.emergencyContact,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}