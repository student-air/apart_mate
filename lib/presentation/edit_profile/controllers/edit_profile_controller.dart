// lib/presentation/edit_profile/controllers/edit_profile_controller.dart

import 'dart:io';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final IAuthRepository authRepository;
  final IProfileRepository profileRepository;

  EditProfileController(this.authRepository, this.profileRepository);

  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final emergencyContactCtrl = TextEditingController();

  final photoPath = ''.obs;
  final selectedGender = RxnString();
  final isLoading = false.obs;

  static const List<String> genders = ['Male', 'Female', 'Other'];
  static const int maxPhotoBytes = 3 * 1024 * 1024; // 3 MB

  void goBack() => Get.back();

  @override
  void onInit() {
    super.onInit();
    _prefill();
  }

  void _prefill() {
    final user = authRepository.currentUser;
    if (user == null) return;

    fullNameCtrl.text = user.fullName;
    phoneCtrl.text = user.phone;
    emailCtrl.text = user.email;
    photoPath.value = user.photoPath ?? '';

    // If profile repo has extra fields, load them here
    // cityCtrl.text = profile?.city ?? '';
    // occupationCtrl.text = profile?.occupation ?? '';
    // emergencyContactCtrl.text = profile?.emergencyContact ?? '';
    // selectedGender.value = profile?.gender;
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.length();

    if (bytes > maxPhotoBytes) {
      AppSnackbar.info(
        'Photo too large',
        'Please select an image under 3 MB',
      );
      return;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust photo',
          toolbarColor: const Color(0xFF0B1220),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF22C55E),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
          statusBarColor: const Color(0xFF0B1220),
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

    final croppedBytes = await File(cropped.path).length();
    if (croppedBytes > maxPhotoBytes) {
      AppSnackbar.info(
        'Photo too large',
        'Cropped image is still over 3 MB',
      );
      return;
    }

    photoPath.value = cropped.path;
  }

  Future<void> saveChanges() async {
    final name = fullNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      AppSnackbar.info(
        'Missing fields',
        'Please fill name, phone and email',
      );
      return;
    }

    final current = authRepository.currentUser;
    if (current == null) {
      AppSnackbar.error('Error', 'No signed-in user');
      return;
    }

    isLoading.value = true;
    try {
      final updated = current.copyWith(
        fullName: name,
        phone: phone,
        email: email,
        photoPath: photoPath.value.isNotEmpty
            ? photoPath.value
            : current.photoPath,
      );

      await authRepository.updateCurrentUser(updated);

      // Optional: save city / occupation / gender / emergency via profileRepository
      // await profileRepository.updateProfile(...);

      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().refresh();
      }

      AppSnackbar.success('Saved', 'Profile updated successfully');
      Get.offNamed(AppRoutes.profile);
    } catch (_) {
      AppSnackbar.error('Failed', 'Could not save changes');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    cityCtrl.dispose();
    occupationCtrl.dispose();
    emergencyContactCtrl.dispose();
    super.onClose();
  }
}