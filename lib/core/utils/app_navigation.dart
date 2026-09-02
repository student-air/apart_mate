// lib/core/utils/app_navigation.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static AppSession get _session => Get.find<AppSession>();

  static bool get isTenant {
    if (Get.isRegistered<AppSession>()) return _session.isTenant;
    final auth = Get.find<IAuthRepository>();
    return (auth.currentUser?.role ?? '').toLowerCase() == 'tenant';
  }

  /// Simple home: tenant dashboard or owner dashboard.
  /// Prefer [routeOwner] for owners after login/splash.
  static void goHome() {
    if (isTenant) {
      Get.offAllNamed(AppRoutes.tenantDashboard);
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  /// Owner entry after login / splash / role.
  /// - No join request  → join society code
  /// - Pending/rejected → request status only
  /// - Approved         → property details (no property) or dashboard
  /// Approved users never see join code again.
  static Future<void> routeOwner() async {
    final auth = Get.find<IAuthRepository>();
    final user = auth.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final societyRepo = Get.find<ISocietyRepository>();
    final societyId = await societyRepo.getSocietyIdForUser(user.id);

    // Never requested → join code
    if (societyId == null || societyId.isEmpty) {
      Get.offAllNamed(AppRoutes.joinSociety);
      return;
    }

    final info = await societyRepo.getJoinRequestInfo(
      userId: user.id,
      societyId: societyId,
    );

    if (info.status == Joinrequeststatus.pending ||
        info.status == Joinrequeststatus.rejected) {
      // Only request status until Pro accepts
      Get.offAllNamed(
        AppRoutes.requeststatus,
        arguments: {
          'societyId': societyId,
        },
      );
      return;
    }

    // Approved → never show join code again
    final props =
        await Get.find<IPropertyRepository>().getPropertiesForUser(user.id);
    if (props.isEmpty) {
      Get.offAllNamed(
        AppRoutes.propertyDetails,
        arguments: societyId,
      );
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

    /// Employee / manager entry after splash or login.
  static Future<void> routeEmployee() async {
    final auth = Get.find<IAuthRepository>();
    final user = auth.currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // 1) Already joined as property manager?
    final manager = await Get.find<IManagerRepository>()
        .getManagerByUserId(user.id);
    if (manager != null && manager.status == 'joined') {
      Get.offAllNamed(AppRoutes.managerDashboard);
      return;
    }

    final societyRepo = Get.find<ISocietyRepository>();
    final societyId = await societyRepo.getSocietyIdForUser(user.id);

    // 2) Never submitted staff request → join code
    if (societyId == null || societyId.isEmpty) {
      Get.offAllNamed(AppRoutes.employeeJoinCode);
      return;
    }

    final info = await societyRepo.getJoinRequestInfo(
      userId: user.id,
      societyId: societyId,
    );

    // 3) Pending / rejected → request status only
    if (info.status == Joinrequeststatus.pending ||
        info.status == Joinrequeststatus.rejected) {
      Get.offAllNamed(
        AppRoutes.requeststatus,
        arguments: {
          'societyId': societyId,
          'type': 'staff',
        },
      );
      return;
    }

    // 4) Approved staff → employee dashboard
    if (info.status == Joinrequeststatus.approved) {
      Get.offAllNamed(AppRoutes.employeeDashboard);
      return;
    }

    Get.offAllNamed(AppRoutes.employeeJoinCode);
  }

  /// Drawer: switch owner ↔ tenant
  static Future<void> handleSwitchRole() async {
    final session = _session;
    final wantTenant = !session.isTenant;

    // Both roles registered → instant switch
    if (session.canSwitchRole) {
      session.switchRole();
      if (Get.key.currentState?.canPop() == true) Get.back();
      if (session.isTenant) {
        Get.offAllNamed(AppRoutes.tenantDashboard);
      } else {
        await routeOwner();
      }
      return;
    }

    // Owner only → register as tenant
    if (wantTenant && !session.hasTenantRole.value) {
      if (Get.key.currentState?.canPop() == true) Get.back();
      final yes = await _confirmDialog(
        title: 'Register as Tenant?',
        message:
            'You are only using the owner role. Do you want to register yourself as a tenant?',
      );
      if (yes == true) {
        Get.toNamed(AppRoutes.tenantJoinCode);
      }
      return;
    }

    // Tenant only → not registered as owner → join society flow
    if (!wantTenant && !session.hasOwnerRole.value) {
      if (Get.key.currentState?.canPop() == true) Get.back();
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
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusFull),
                    ),
                  ),
                  child: Text(
                    'Yes',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.accentGreen),
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