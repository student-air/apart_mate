import 'package:apart_mate/core/session/app_session.dart';
import 'package:get/get.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static bool get isTenant {
    if (Get.isRegistered<AppSession>()) {
      return Get.find<AppSession>().isTenant;
    }
    final auth = Get.find<IAuthRepository>();
    return (auth.currentUser?.role ?? '').toLowerCase() == 'tenant';
  }

  static void goHome() {
    if (isTenant) {
      Get.offNamed(AppRoutes.tenantDashboard);
    } else {
      Get.offNamed(AppRoutes.dashboard);
    }
  }

  static void switchRoleAndGoHome() {
    final session = Get.find<AppSession>();
    session.switchRole();
    goHome();
  }
}