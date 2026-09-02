// lib/presentation/splash/controllers/splash_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/data/repositories/firebase_auth_repository.dart';
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
    if (Get.currentRoute != AppRoutes.splash) return;

    final authRepository = Get.find<IAuthRepository>();

    UserModel? user = authRepository.currentUser;
    if (user == null && authRepository is FirebaseAuthRepository) {
      user = await authRepository.restoreSession();
    }

    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (user.role.isEmpty) {
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }

        final role = user.role.toLowerCase();
    if (Get.isRegistered<AppSession>()) {
      Get.find<AppSession>().setRole(role);
    }

    if (role == 'owner') {
      await AppNavigation.routeOwner();
    } else if (role == 'employee') {
      await AppNavigation.routeEmployee();
    } else {
      // tenant (and any other)
      AppNavigation.goHome();
    }
  }
}