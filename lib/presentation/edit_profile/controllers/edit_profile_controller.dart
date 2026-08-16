import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/utils/validators.dart';
import 'package:apart_mate/data/models/profile_model.dart';
import 'package:apart_mate/data/models/user_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';
import 'package:apart_mate/presentation/profile_setup/controllers/profile_setup_controller.dart';

class EditProfileController extends GetxController {
  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;

  EditProfileController(this._authRepository, this._profileRepository);

  static const genders = ProfileSetupController.genders;

  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final occupationCtrl = TextEditingController();
  final emergencyContactCtrl = TextEditingController();

  final selectedGender = RxnString();
  final photoPath = RxnString();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prefill();
  }

  Future<void> _prefill() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    fullNameCtrl.text = user.fullName;
    phoneCtrl.text = user.phone;
    emailCtrl.text = user.email;
    photoPath.value = user.photoPath;

    final profile = await _profileRepository.getProfile(user.id);
    if (profile != null) {
      selectedGender.value =
          profile.gender.isEmpty ? null : profile.gender;
      cityCtrl.text = profile.city;
      occupationCtrl.text = profile.occupation;
      emergencyContactCtrl.text = profile.emergencyContact;
    }
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      photoPath.value = picked.path;
    }
  }

  Future<void> save() async {
    final current = _authRepository.currentUser;
    if (current == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      return;
    }

    final name = fullNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final email = emailCtrl.text.trim();

    if (name.isEmpty) {
      AppSnackbar.error('Missing info', 'Please enter your full name');
      return;
    }
    final phoneError = Validators.phoneErrorMessage(phone);
    if (phoneError != null) {
      AppSnackbar.error('Invalid phone', phoneError);
      return;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      AppSnackbar.error('Invalid email', 'Please enter a valid email');
      return;
    }

    isLoading.value = true;
    try {
      // Extended profile
      await _profileRepository.saveProfile(
        ProfileModel(
          userId: current.id,
          gender: selectedGender.value ?? '',
          city: cityCtrl.text.trim(),
          occupation: occupationCtrl.text.trim(),
          emergencyContact: emergencyContactCtrl.text.trim(),
        ),
      );

      // Core user fields (add updateCurrentUser on auth if missing)
      final updated = current.copyWith(
        fullName: name,
        phone: phone,
        email: email,
        photoPath: photoPath.value,
      );
      await _authRepository.updateCurrentUser(updated);

      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().refresh();
      }

      AppSnackbar.success('Saved', 'Profile updated');
      Get.back();
    } catch (e) {
      AppSnackbar.error('Failed', 'Could not save profile');
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() => Get.back();

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