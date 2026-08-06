// lib/domain/repositories/i_profile_repository.dart

import 'package:apart_mate/data/models/profile_model.dart';

abstract class IProfileRepository {
  /// Returns null if the user hasn't completed profile setup yet.
  Future<ProfileModel?> getProfile(String userId);

  /// Creates or overwrites the profile for [profile.userId].
  Future<void> saveProfile(ProfileModel profile);
}