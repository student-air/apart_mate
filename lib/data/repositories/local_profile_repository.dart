// lib/data/repositories/local/local_profile_repository.dart

import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';

/// Mock in-memory profile repository, keyed by userId.
class LocalProfileRepository implements IProfileRepository {
  final Map<String, ProfileModel> _profiles = {};

  Future<void> _simulateLatency() =>
      Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    await _simulateLatency();
    return _profiles[userId];
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    await _simulateLatency();
    _profiles[profile.userId] = profile;
  }
}