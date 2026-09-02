// lib/presentation/employee_dashboard/controllers/employee_dashboard_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class EmployeeDashboardController extends GetxController {
  final isLoading = true.obs;
  final society = Rxn<SocietyModel>();
  final userName = ''.obs;

  late final IAuthRepository _auth;
  late final ISocietyRepository _societyRepo;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<IAuthRepository>();
    _societyRepo = Get.find<ISocietyRepository>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      // Use the field your UserModel has: fullName / name / email
      userName.value =
          user?.fullName ?? user?.email ?? 'Staff';

      if (user != null) {
        final societyId =
            await _societyRepo.getSocietyIdForUser(user.id);
        if (societyId != null && societyId.isNotEmpty) {
          society.value =
              await _societyRepo.getSocietyById(societyId);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => load();

  void openProfile() => Get.toNamed(AppRoutes.profile);

  void openUpdates() => Get.toNamed(AppRoutes.updates);

  void openComplaints() => Get.toNamed(AppRoutes.complaint);
}