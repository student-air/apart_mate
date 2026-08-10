// lib/presentation/profile/bindings/profile_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_profile_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<IAuthRepository>(),
        Get.find<IProfileRepository>(),
        Get.find<ISocietyRepository>(),
      ),
    );
  }
}