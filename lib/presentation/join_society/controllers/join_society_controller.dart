// lib/presentation/join_society/controllers/join_society_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class JoinSocietyController extends GetxController {
  final IAuthRepository _authRepository;
  final ISocietyRepository _societyRepository;
  JoinSocietyController(this._authRepository, this._societyRepository);

  static const codeLength = 6;

  final digitCtrls = List.generate(codeLength, (_) => TextEditingController());
  final focusNodes = List.generate(codeLength, (_) => FocusNode());

  final society = Rxn<SocietyModel>();
  final isLookingUp = false.obs;
  final isJoining = false.obs;
  final lookupFailed = false.obs;

  String get _enteredCode => digitCtrls.map((c) => c.text).join();

  /// Used by the view to show Independent Owner option only for owners
  String? get currentUserRole => _authRepository.currentUser?.role;

  void onDigitChanged(int index, String value) {
    lookupFailed.value = false;

    if (value.isNotEmpty && index < codeLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (_enteredCode.length == codeLength) {
      FocusScope.of(Get.context!).unfocus();
      _lookupSociety();
    } else {
      society.value = null;
    }
  }

  void onBackspace(int index) {
    if (digitCtrls[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
      digitCtrls[index - 1].clear();
    }
  }

  Future<void> _lookupSociety() async {
    isLookingUp.value = true;
    try {
      final result = await _societyRepository.getSocietyByJoinCode(_enteredCode);
      society.value = result;
      lookupFailed.value = result == null;
      if (result == null) {
        AppSnackbar.error('Invalid code', 'No society found for that code');
      }
    } finally {
      isLookingUp.value = false;
    }
  }

  Future<void> continueWithSociety() async {
    final matchedSociety = society.value;
    if (matchedSociety == null) return;

    final user = _authRepository.currentUser;
    if (user == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isJoining.value = true;
    try {
      await _societyRepository.joinSociety(userId: user.id, societyId: matchedSociety.id);
      AppSnackbar.success('Request sent', 'Your request to join ${matchedSociety.name} was submitted');

      if (user.role == 'tenant') {
        Get.offNamed(AppRoutes.requeststatus, arguments: matchedSociety.id);
      } else {
        Get.offNamed(AppRoutes.propertyDetails, arguments: matchedSociety.id);
      }
    } finally {
      isJoining.value = false;
    }
  }

  /// Independent Owner path — no society code needed
  Future<void> continueAsIndependentOwner() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isJoining.value = true;
    try {
      // Simply navigate to Property Details in independent mode
      // We pass `null` so PropertyDetailsController knows it's independent
      Get.offNamed(AppRoutes.propertyDetails, arguments: null);
    } catch (e) {
      AppSnackbar.error('Something went wrong', 'Please try again');
    } finally {
      isJoining.value = false;
    }
  }

  void goBack() {
    Get.back();
  }

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