import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';

class MaintenanceController extends GetxController {
  final isLoading = false.obs;
  final items = <ComplaintModel>[].obs;
  final selectedTab = 0.obs; // 0 = All, 1 = Open, 2 = Resolved

  late final IComplaintRepository _complaintRepo;
  late final IAuthRepository _auth;

  bool get isTenant => AppNavigation.isTenant;

  @override
  void onInit() {
    super.onInit();
    _complaintRepo = Get.find<IComplaintRepository>();
    _auth = Get.find<IAuthRepository>();
    load();
  }

  List<ComplaintModel> get filtered {
    final list = items;
    if (selectedTab.value == 1) {
      return list.where((c) => c.status == 'open' || c.status == 'reviewed').toList();
    }
    if (selectedTab.value == 2) {
      return list.where((c) => c.status == 'resolved').toList();
    }
    return list;
  }

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      if (isTenant) {
        // Tenant: only what they raised
        items.assignAll(await _complaintRepo.getComplaintsRaisedBy(user.id));
      } else {
        // Owner: inbox assigned to owner
        items.assignAll(await _complaintRepo.getComplaintsForOwner(user.id));
      }
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(int index) => selectedTab.value = index;

  Future<void> updateStatus(ComplaintModel c, String status) async {
    if (isTenant) return; // tenant cannot change status
    await _complaintRepo.updateStatus(c.id, status);
    await load();
  }
}