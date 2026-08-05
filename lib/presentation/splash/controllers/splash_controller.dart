import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
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
    // (e.g. user taps skip right as the delay finishes).
    if (Get.currentRoute != AppRoutes.splash) return;

    final authRepository = Get.find<IAuthRepository>();
    final user = authRepository.currentUser;

    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (user.role.isEmpty) {
      // role_selection isn't built yet — avoid navigating to an
      // unregistered route, which would crash.
      AppSnackbar.info('Coming soon', 'Role selection screen is under construction');
      return;
    }

    // dashboard isn't built yet either — same guard.
    AppSnackbar.info('Coming soon', 'Dashboard screen is under construction');
  }
}