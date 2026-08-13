import 'package:get/get.dart';

class AppSession extends GetxController {
  /// 'owner' | 'tenant'
  final currentRole = 'owner'.obs;

  bool get isTenant => currentRole.value == 'tenant';

  void setRole(String role) {
    currentRole.value = role.toLowerCase();
  }

  void switchRole() {
    currentRole.value = isTenant ? 'owner' : 'tenant';
  }

}

