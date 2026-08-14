import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static AppSession get _session => Get.find<AppSession>();

  static bool get isTenant {
    if (Get.isRegistered<AppSession>()) return _session.isTenant;
    final auth = Get.find<IAuthRepository>();
    return (auth.currentUser?.role ?? '').toLowerCase() == 'tenant';
  }

  static void goHome() {
    if (isTenant) {
      Get.offAllNamed(AppRoutes.tenantDashboard);
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  /// Call this from the drawer switch button
  static Future<void> handleSwitchRole() async {
  final session = _session;
  final wantTenant = !session.isTenant;

  // Both roles fully registered → instant switch
  if (session.canSwitchRole) {
    session.switchRole();
    if (Get.key.currentState?.canPop() == true) Get.back();
    goHome();
    return;
  }

  // Owner only → register as tenant
if (wantTenant && !session.hasTenantRole.value) {
  if (Get.key.currentState?.canPop() == true) Get.back(); // close drawer
  final yes = await _confirmDialog(
    title: 'Register as Tenant?',
    message:
        'You are only using the owner role. Do you want to register yourself as a tenant?',
  );
  if (yes == true) {
    Get.toNamed(AppRoutes.tenantJoinCode); // NOT role selection, NOT dashboard
  }
  return;
}

   // Tenant only → not registered as owner → go straight to join society
  if (!wantTenant && !session.hasOwnerRole.value) {
    if (Get.key.currentState?.canPop() == true) Get.back(); // close drawer
    Get.toNamed(AppRoutes.joinSociety);
    return;
  }
  
  }

  static Future<bool?> _confirmDialog({
    required String title,
    required String message,
  }) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
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
                    backgroundColor: AppColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Yes',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'No',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}