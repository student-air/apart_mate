// lib/presentation/join_society/bindings/join_society_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/join_society/controllers/join_society_controller.dart';

class JoinSocietyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinSocietyController>(
      () => JoinSocietyController(
        Get.find<IAuthRepository>(),
        Get.find<ISocietyRepository>(),
      ),
    );
  }
}