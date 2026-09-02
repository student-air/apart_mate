// lib/presentation/employee_join_code/controllers/employee_join_code_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class EmployeeJoinCodeController extends GetxController {
  static const codeLength = 6;

  final digitCtrls = List.generate(codeLength, (_) => TextEditingController());
  final focusNodes = List.generate(codeLength, (_) => FocusNode());

  final isLookingUp = false.obs;
  final isContinuing = false.obs;
  final lookupFailed = false.obs;
  final matchedLabel = RxnString();

  late final IAuthRepository _auth;
  late final IManagerRepository _managers;
  late final ISocietyRepository _societies;

  String get enteredCode =>
      digitCtrls.map((c) => c.text).join().trim().toUpperCase();

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<IAuthRepository>();
    _managers = Get.find<IManagerRepository>();
    _societies = Get.find<ISocietyRepository>();
    _redirectIfAlreadyLinked();
  }

  /// If already manager / pending staff / approved staff, leave this screen.
  Future<void> _redirectIfAlreadyLinked() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final manager = await _managers.getManagerByUserId(user.id);
      if (manager != null && manager.status == 'joined') {
        Get.offAllNamed(AppRoutes.dashboard);
        return;
      }

      final societyId = await _societies.getSocietyIdForUser(user.id);
      if (societyId == null || societyId.isEmpty) return;

      final info = await _societies.getJoinRequestInfo(
        userId: user.id,
        societyId: societyId,
      );

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

      if (info.status == Joinrequeststatus.approved) {
        Get.offAllNamed(AppRoutes.employeeDashboard);
      }
    } catch (_) {
      // Stay on join code if lookup fails
    }
  }

  void onDigitChanged(int index, String value) {
    lookupFailed.value = false;
    matchedLabel.value = null;

    if (value.isNotEmpty) {
      final char = value.characters.last.toUpperCase();
      digitCtrls[index].text = char;
      digitCtrls[index].selection =
          TextSelection.collapsed(offset: char.length);
    }

    if (value.isNotEmpty && index < codeLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (enteredCode.length == codeLength) {
      FocusScope.of(Get.context!).unfocus();
    }
  }

  void onBackspace(int index) {
    if (digitCtrls[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
      digitCtrls[index - 1].clear();
    }
  }

    Future<void> continueWithCode() async {
    if (enteredCode.length != codeLength) {
      AppSnackbar.error('Incomplete code', 'Enter the 6-character code');
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isContinuing.value = true;
    lookupFailed.value = false;

    try {
      // ——— 1) Manager invite first ———
      final manager = await _managers.getManagerByCode(enteredCode);
      if (manager != null) {
        await _managers.markManagerJoined(
          managerId: manager.id,
          userId: user.id,
        );
        AppSnackbar.success(
          'Welcome',
          manager.propertyLabel.isEmpty
              ? 'You joined as manager'
              : 'You joined as manager for ${manager.propertyLabel}',
        );
        // Temporary owner → same home as owner
        Get.offAllNamed(AppRoutes.dashboard);
        return;
      }

      // ——— 2) Society code → staff request ———
      final society = await _societies.getSocietyByJoinCode(enteredCode);
      if (society != null) {
        await _societies.joinAsStaff(
          userId: user.id,
          societyId: society.id,
        );
        AppSnackbar.success(
          'Request sent',
          'Waiting for society admin approval',
        );
        Get.offAllNamed(
          AppRoutes.requeststatus,
          arguments: {
            'societyId': society.id,
            'societyName': society.name,
            'type': 'staff', // so continue goes to employee dashboard
          },
        );
        return;
      }

      // ——— 3) Invalid ———
      lookupFailed.value = true;
      AppSnackbar.error(
        'Invalid code',
        'No society or manager invite found',
      );
    } catch (e) {
      lookupFailed.value = true;
      AppSnackbar.error('Lookup failed', e.toString());
    } finally {
      isContinuing.value = false;
    }
  }
  
  void goBack() => Get.back();

  @override
  void onClose() {
    for (final c in digitCtrls) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}