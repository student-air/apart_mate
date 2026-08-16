// lib/presentation/profile_setup/controllers/profile_setup_controller.dart

//import 'dart:io';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:apart_mate/core/utils/validators.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class ProfileSetupController extends GetxController {
  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;
  ProfileSetupController(this._authRepository, this._profileRepository);

  static const currentStep = 3;
  static const totalSteps = 5;
  static const int maxBytes = 3 * 1024 * 1024; // 3 MB
  static const double cropRatio = 1 / 1;

  static const genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  final fullNameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final emergencyContactCtrl = TextEditingController();

  final selectedGender = RxnString();
  final photoPath = RxnString();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final current = _authRepository.currentUser;
    if (current != null) {
      fullNameCtrl.text = current.fullName;
      photoPath.value = current.photoPath;
    }
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      photoPath.value = picked.path;
    }
  }

  Future<void> saveAndContinue() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (fullNameCtrl.text.trim().isEmpty) {
      AppSnackbar.error('Missing info', 'Please enter your full name');
      return;
    }
    if (selectedGender.value == null) {
      AppSnackbar.error('Missing info', 'Please select your gender');
      return;
    }
    if (cityCtrl.text.trim().isEmpty) {
      AppSnackbar.error('Missing info', 'Please enter your city');
      return;
    }
    final phoneError = Validators.phoneErrorMessage(emergencyContactCtrl.text);
    if (phoneError != null) {
      AppSnackbar.error('Invalid contact', phoneError);
      return;
    }

    isLoading.value = true;
    try {
      await _profileRepository.saveProfile(
        ProfileModel(
          userId: user.id,
          gender: selectedGender.value!,
          city: cityCtrl.text.trim(),
          occupation: occupationCtrl.text.trim(),
          emergencyContact: emergencyContactCtrl.text.trim(),
        ),
      );
      Get.offNamed(AppRoutes.roleSelection);
    } finally {
      isLoading.value = false;
    }
  }

    Future<void> pickAndCropPhoto() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 95,
  );
  if (picked == null) return;

  final file = File(picked.path);
  final size = await file.length();

  if (size > maxBytes) {
    AppSnackbar.info(
      'Photo too large',
      'Please choose an image under 3 MB',
    );
    return;
  }

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // fixed frame
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Adjust photo',
        toolbarColor: const Color(0xFF0B1220), // primaryDark-ish
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: const Color(0xFF22C55E), // accent green
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true, // user can only move/zoom, not change ratio
        hideBottomControls: false,
      ),
      IOSUiSettings(
        title: 'Adjust photo',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
        aspectRatioPickerButtonHidden: true,
      ),
    ],
  );

  if (cropped == null) return;

  // Optional: re-check size after crop
  final croppedFile = File(cropped.path);
  final croppedSize = await croppedFile.length();
  if (croppedSize > maxBytes) {
    AppSnackbar.info(
      'Photo too large',
      'Cropped image is still over 3 MB. Try another photo.',
    );
    return;
  }

  // Save path into your state (e.g. photoPath / selectedImage)
  photoPath.value = cropped.path;
}

  void goBack() {
    Get.back();
  }
  @override
  void onClose() {
    fullNameCtrl.dispose();
    cityCtrl.dispose();
    occupationCtrl.dispose();
    emergencyContactCtrl.dispose();
    super.onClose();
  }
}