import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _init();
  }

  void skip() => _goToNext();

  Future<void> _init() async {
    if (Get.context != null) {
      await precacheImage(
        const AssetImage('assets/images/logo.png'),
        Get.context!,
      );
    }
    await Future.delayed(const Duration(milliseconds: 2200));
    await _goToNext();
  }

  Future<void> _goToNext() async {
    // Guard against skip() firing after _init() already navigated
    if (Get.currentRoute != AppRoutes.splash) return;

    final authRepository = Get.find<IAuthRepository>();
    final user = authRepository.currentUser;

    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (user.role.isEmpty) {
      // Signed in but never finished onboarding
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }

    // Set session role from saved user
    final role = user.role.toLowerCase();
    if (Get.isRegistered<AppSession>()) {
      Get.find<AppSession>().setRole(role);
    }

    // Owner → /dashboard, Tenant → /tenant-dashboard
    AppNavigation.goHome();
  }
}