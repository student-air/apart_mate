// lib/presentation/manager_dashboard/controllers/manager_dashboard_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/data/models/manager_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class ManagerDashboardController extends GetxController {
  final isLoading = true.obs;
  final manager = Rxn<ManagerModel>();
  final userName = ''.obs;

  late final IAuthRepository _auth;
  late final IManagerRepository _managers;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<IAuthRepository>();
    _managers = Get.find<IManagerRepository>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      userName.value = user?.fullName ?? user?.email ?? 'Manager';

      if (user != null) {
        manager.value = await _managers.getManagerByUserId(user.id);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => load();

  void openProfile() => Get.toNamed(AppRoutes.profile);

  void openUpdates() => Get.toNamed(AppRoutes.updates);
}