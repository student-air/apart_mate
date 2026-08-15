import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/data/models/complaint_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_complaint_repository.dart';

class ComplaintListController extends GetxController {
  final isLoading = false.obs;
  final selectedTab = 0.obs; // 0 = All (inbox), 1 = My complaints
  final inbox = <ComplaintModel>[].obs;
  final mine = <ComplaintModel>[].obs;

  late final IComplaintRepository _repo;
  late final IAuthRepository _auth;

  bool get isTenant => AppNavigation.isTenant;

  List<ComplaintModel> get visible {
    if (isTenant) return mine;
    return selectedTab.value == 0 ? inbox : mine;
  }

  @override
  void onInit() {
    super.onInit();
    _repo = Get.find<IComplaintRepository>();
    _auth = Get.find<IAuthRepository>();
    load();
  }

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      mine.assignAll(await _repo.getComplaintsRaisedBy(user.id));
      if (!isTenant) {
        inbox.assignAll(await _repo.getComplaintsForOwner(user.id));
      }
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(int i) => selectedTab.value = i;

  Future<void> updateStatus(String id, String status) async {
    if (isTenant) return;
    await _repo.updateStatus(id, status);
    await load();
  }

  Future<void> deleteComplaint(String id) async {
  await _repo.deleteComplaint(id);
  inbox.removeWhere((c) => c.id == id);
  mine.removeWhere((c) => c.id == id);
}
}