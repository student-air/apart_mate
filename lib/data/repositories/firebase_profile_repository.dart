// lib/data/repositories/firebase_profile_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';

class FirebaseProfileRepository implements IProfileRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('profiles');

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    if (userId.isEmpty) return null;

    final doc = await _col.doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;

    return _fromMap(userId, doc.data()!);
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    if (profile.userId.isEmpty) {
      throw ArgumentError('profile.userId is required');
    }

    await _col.doc(profile.userId).set(
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

  ProfileModel _fromMap(String userId, Map<String, dynamic> d) {
    return ProfileModel(
      userId: userId,
      gender: d['gender'] ?? '',
      city: d['city'] ?? '',
      occupation: d['occupation'] ?? '',
      emergencyContact: d['emergencyContact'] ?? '',
    );
  }
}