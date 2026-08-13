// lib/presentation/profile/controllers/profile_controller.dart

import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
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
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log out?', style: AppTextStyles.h4, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'You will need to sign in again to manage your properties.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (confirmed == true) {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
}