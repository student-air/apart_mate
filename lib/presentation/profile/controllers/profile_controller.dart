// lib/presentation/profile/controllers/profile_controller.dart

import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/help_support_sheet.dart';
import 'package:apart_mate/core/widgets/notification_preferences_sheet.dart';
import 'package:apart_mate/core/widgets/privacy_security_sheet.dart';
import 'package:apart_mate/core/widgets/terms_of_service_sheet.dart';
import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileController extends GetxController {
  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;
  final ISocietyRepository _societyRepository;

  ProfileController(
    this._authRepository,
    this._profileRepository,
    this._societyRepository,
  );

  final user = Rxn<UserModel>();
  final profile = Rxn<ProfileModel>();
  final society = Rxn<SocietyModel>();
  final isLoading = true.obs;

  // Owner card (tenant only)
  final ownerName = ''.obs;
  final ownerPhone = ''.obs;
  final ownerEmail = ''.obs;
  final hasOwnerInfo = false.obs;

  // ── Notification preferences ──
  final notifyUpdates = true.obs;
  final notifyComplaints = true.obs;
  final notifyTenantActivity = true.obs; // owner only
  final notifySound = false.obs;

  // ── Privacy & security ──
  final biometricLoginEnabled = false.obs;
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final isChangingPassword = false.obs;

  String get roleLabel {
    if (Get.isRegistered<AppSession>()) {
      final sessionRole = Get.find<AppSession>().currentRole.value;
      if (sessionRole.isNotEmpty) {
        return sessionRole[0].toUpperCase() + sessionRole.substring(1);
      }
    }
    final role = user.value?.role ?? '';
    return role.isEmpty ? '' : role[0].toUpperCase() + role.substring(1);
  }

  bool get isTenant => AppNavigation.isTenant;

  String get societyContactNumber => society.value?.phone ?? '';

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

      ownerName.value = '';
      ownerPhone.value = '';
      ownerEmail.value = '';
      hasOwnerInfo.value = false;

      final societyId =
          await _societyRepository.getSocietyIdForUser(currentUser.id);
      final results = await Future.wait([
        _profileRepository.getProfile(currentUser.id),
        if (societyId != null)
          _societyRepository.getSocietyById(societyId)
        else
          Future.value(null),
      ]);
      profile.value = results[0] as ProfileModel?;
      society.value = results[1] as SocietyModel?;

      if (isTenant && Get.isRegistered<ITenantRepository>()) {
        final tenantRepo = Get.find<ITenantRepository>();
        final t = await tenantRepo.getTenantForUser(currentUser.id);

        if (t != null) {
          ownerName.value = t.ownerName;
          ownerPhone.value = t.ownerPhone;
          ownerEmail.value = t.ownerEmail;
          hasOwnerInfo.value = t.ownerName.trim().isNotEmpty ||
              t.ownerPhone.trim().isNotEmpty ||
              t.ownerEmail.trim().isNotEmpty;

          if (society.value == null &&
              t.propertyId.isNotEmpty &&
              Get.isRegistered<IPropertyRepository>()) {
            final p = await Get.find<IPropertyRepository>()
                .getPropertyById(t.propertyId);
            if (p != null && p.societyId.isNotEmpty) {
              society.value =
                  await _societyRepository.getSocietyById(p.societyId);
            }
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openPhone(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppSnackbar.error('Call failed', 'Could not open phone dialer');
    }
  }

  Future<void> openEmail(String email) async {
    if (email.trim().isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      AppSnackbar.error('Email failed', 'Could not open mail app');
    }
  }

  Future<void> refresh() => loadProfile();

  void goToEditProfile() => Get.toNamed(AppRoutes.editProfile);

  // ── Settings sheets ──
  void openNotificationPreferences() => showNotificationPreferencesSheet();
  void openPrivacyAndSecurity() => showPrivacySecuritySheet();
  void openHelpAndSupport() => showHelpSupportSheet();
  void openTermsOfService() => showTermsOfServiceSheet();

  void setNotifyUpdates(bool value) => notifyUpdates.value = value;
  void setNotifyComplaints(bool value) => notifyComplaints.value = value;
  void setNotifyTenantActivity(bool value) => notifyTenantActivity.value = value;
  void setNotifySound(bool value) => notifySound.value = value;

  void toggleBiometricLogin(bool value) {
    biometricLoginEnabled.value = value;
    AppSnackbar.info(
      value ? 'Biometric enabled' : 'Biometric disabled',
      value
          ? 'Fingerprint / face unlock is on (local preference)'
          : 'Password will be required to sign in',
    );
  }

  Future<void> changePassword() async {
    final current = currentPasswordCtrl.text.trim();
    final next = newPasswordCtrl.text.trim();
    final confirm = confirmPasswordCtrl.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      AppSnackbar.info('Missing fields', 'Fill all password fields');
      return;
    }
    if (next.length < 8) {
      AppSnackbar.info('Weak password', 'Use at least 8 characters');
      return;
    }
    if (next != confirm) {
      AppSnackbar.error('Mismatch', 'New passwords do not match');
      return;
    }

    isChangingPassword.value = true;
    try {
      // Prefer real re-auth + update when you add it to IAuthRepository.
      // For now: send reset email as a reliable Firebase path.
      final email = user.value?.email ?? '';
      if (email.isEmpty) {
        AppSnackbar.error('No email', 'Account has no email for reset');
        return;
      }
      await _authRepository.sendPasswordResetEmail(email);
      currentPasswordCtrl.clear();
      newPasswordCtrl.clear();
      confirmPasswordCtrl.clear();
      Get.back();
      AppSnackbar.success(
        'Reset link sent',
        'Check $email to set a new password',
      );
    } catch (e) {
      AppSnackbar.error('Failed', e.toString());
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> sendPasswordResetLink() async {
    final email = user.value?.email ?? '';
    if (email.isEmpty) {
      AppSnackbar.error('No email', 'Account has no email');
      return;
    }
    try {
      await _authRepository.sendPasswordResetEmail(email);
      AppSnackbar.success('Reset link sent', 'Check $email');
    } catch (e) {
      AppSnackbar.error('Reset failed', e.toString());
    }
  }

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
                'You will need to sign in again to access Apart Mate.',
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

  @override
  void onClose() {
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}