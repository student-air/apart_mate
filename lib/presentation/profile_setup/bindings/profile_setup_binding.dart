// lib/presentation/profile_setup/bindings/profile_setup_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/presentation/profile_setup/controllers/profile_setup_controller.dart';

class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSetupController>(
      () => ProfileSetupController(
        Get.find<IAuthRepository>(),
        Get.find<IProfileRepository>(),
      ),
    );
  }
}