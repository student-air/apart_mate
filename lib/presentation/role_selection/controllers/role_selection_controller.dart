// lib/presentation/role_selection/controllers/role_selection_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class RoleOption {
  final String value;
  final String title;
  final String description;
  final String icon; // Icons.* name resolved in the view

  const RoleOption({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class RoleSelectionController extends GetxController {
  final IAuthRepository _authRepository;
  RoleSelectionController(this._authRepository);

  static const roles = [
    RoleOption(
      value: 'owner',
      title: 'Owner',
      description: 'I own property in a society',
      icon: 'owner',
    ),
    RoleOption(
      value: 'tenant',
      title: 'Tenant',
      description: 'I rent a property ',
      icon: 'tenant',
    ),
    RoleOption(
      value: 'employee',
      title: 'Employee',
      description: 'I provide my services to this society',
      icon: 'employee',
    ),
  ];

  final selectedRole = RxnString();
  final isLoading = false.obs;

  void selectRole(String value) => selectedRole.value = value;

  Future<void> continueWithRole() async {
    if (selectedRole.value == null) {
      AppSnackbar.error('Select a role', 'Please choose how you\'ll use apart_mate');
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.updateUserRole(selectedRole.value!);

      if (selectedRole.value == 'tenant') {
        Get.offNamed(AppRoutes.tenantJoinCode);
      } else {
      Get.offNamed(AppRoutes.joinSociety);
      }
    } catch (e) {
      AppSnackbar.error('Something went wrong', 'Please try again');
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }
}