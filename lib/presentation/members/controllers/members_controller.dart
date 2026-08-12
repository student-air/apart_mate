import 'package:get/get.dart';
import 'package:apart_mate/data/models/tenant_model.dart';
import 'package:apart_mate/domain/repositories/i_tenant_repository.dart';

class MembersController extends GetxController {
  final isLoading = false.obs;
  final tenants = <TenantModel>[].obs;
  final selectedTab = 0.obs; // 0 = Tenants, 1 = Managers

  late final ITenantRepository _tenantRepo;

  @override
  void onInit() {
    super.onInit();
    _tenantRepo = Get.find<ITenantRepository>();
    loadMembers();
  }

  Future<void> loadMembers() async {
    isLoading.value = true;
    try {
      final list = await _tenantRepo.getTenantsForOwner('current_owner');
      tenants.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(int index) {
    selectedTab.value = index;
  }
}