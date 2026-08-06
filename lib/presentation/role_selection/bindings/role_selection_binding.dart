// lib/presentation/role_selection/bindings/role_selection_binding.dart

import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/presentation/role_selection/controllers/role_selection_controller.dart';

class RoleSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleSelectionController>(
      () => RoleSelectionController(Get.find<IAuthRepository>()),
    );
  }
}