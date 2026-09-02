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

  String get _enteredCode =>
      digitCtrls.map((c) => c.text).join().trim().toUpperCase();

  /// Used by the view to show Independent Owner option only for owners
  String? get currentUserRole => _authRepository.currentUser?.role;

  @override
  void onInit() {
    super.onInit();
    _redirectIfAlreadyRequested();
  }

  /// If user already has a join request, never stay on join-code screen.
  Future<void> _redirectIfAlreadyRequested() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final societyId = await _societyRepository.getSocietyIdForUser(user.id);
    if (societyId == null || societyId.isEmpty) return;

    final info = await _societyRepository.getJoinRequestInfo(
      userId: user.id,
      societyId: societyId,
    );

    if (info.status == Joinrequeststatus.pending ||
        info.status == Joinrequeststatus.rejected) {
      Get.offAllNamed(
        AppRoutes.requeststatus,
        arguments: {'societyId': societyId},
      );
      return;
    }

    if (info.status == Joinrequeststatus.approved) {
      // Never show join code again after approval
      Get.offAllNamed(
        AppRoutes.propertyDetails,
        arguments: societyId,
      );
    }
  }

  void onDigitChanged(int index, String value) {
    lookupFailed.value = false;

    if (value.isNotEmpty) {
      final char = value.characters.last.toUpperCase();
      digitCtrls[index].text = char;
      digitCtrls[index].selection =
          TextSelection.collapsed(offset: char.length);
    }

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
      final code = _enteredCode;

      if (code.length != codeLength) {
        society.value = null;
        return;
      }

      final result = await _societyRepository.getSocietyByJoinCode(code);
      society.value = result;
      lookupFailed.value = result == null;

      if (result == null) {
        AppSnackbar.error('Invalid code', 'No society found for that code');
      }
    } catch (e) {
      lookupFailed.value = true;
      society.value = null;
      AppSnackbar.error('Lookup failed', 'Please try again');
    } finally {
      isLookingUp.value = false;
    }
  }

  Future<void> continueWithSociety() async {
    final matchedSociety = society.value;
    if (matchedSociety == null) {
      AppSnackbar.error('No society', 'Enter a valid join code first');
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    isJoining.value = true;
    try {
      await _societyRepository.joinSociety(
        userId: user.id,
        societyId: matchedSociety.id,
      );

      // Pending request → request status only
      Get.offAllNamed(
        AppRoutes.requeststatus,
        arguments: {
          'societyId': matchedSociety.id,
          'societyName': matchedSociety.name,
        },
      );
    } catch (e) {
      AppSnackbar.error('Join failed', e.toString());
    } finally {
      isJoining.value = false;
    }
  }

  Future<void> continueAsIndependentOwner() async {
  AppSnackbar.info(
    'Under production',
    'This feature is under production and will be available soon',
  );
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