import 'package:get/get.dart';

class AppSession extends GetxController {
  /// Active UI role: 'owner' | 'tenant'
  final currentRole = 'owner'.obs;

  /// Whether the user has completed each role path at least once
  final hasOwnerRole = false.obs;
  final hasTenantRole = false.obs;

  bool get isTenant => currentRole.value == 'tenant';

  bool get canSwitchRole => hasOwnerRole.value && hasTenantRole.value;

  void setRole(String role) {
    currentRole.value = role.toLowerCase();
  }

  /// Call when owner onboarding is done (e.g. after join society / approved)
  void registerOwner() {
    hasOwnerRole.value = true;
    currentRole.value = 'owner';
  }

  /// Call when tenant onboarding is done (e.g. after join code + confirm)
  void registerTenant() {
    hasTenantRole.value = true;
    currentRole.value = 'tenant';
  }

  /// Only toggles if both roles are registered
  void switchRole() {
    if (!canSwitchRole) return;
    currentRole.value = isTenant ? 'owner' : 'tenant';
  }
}