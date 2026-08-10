// lib/presentation/profile/controllers/profile_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';

class ProfileController extends GetxController {
  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;
  final ISocietyRepository _societyRepository;
  ProfileController(this._authRepository, this._profileRepository, this._societyRepository);

  final user = Rxn<UserModel>();
  final profile = Rxn<ProfileModel>();
  final society = Rxn<SocietyModel>();
  final isLoading = true.obs;

  String get roleLabel {
    final role = user.value?.role ?? '';
    return role.isEmpty ? '' : role[0].toUpperCase() + role.substring(1);
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) return;

    isLoading.value = true;
    try {
      user.value = currentUser;

      final societyId = await _societyRepository.getSocietyIdForUser(currentUser.id);
      final results = await Future.wait([
        _profileRepository.getProfile(currentUser.id),
        if (societyId != null) _societyRepository.getSocietyById(societyId) else Future.value(null),
      ]);
      profile.value = results[0] as ProfileModel?;
      society.value = results[1] as SocietyModel?;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadProfile();

  void goToEditProfile() => Get.toNamed(AppRoutes.editProfile);

  Future<void> confirmLogout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Log Out')),
        ],
      ),
    );

    if (confirmed == true) {
      await _authRepository.logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}