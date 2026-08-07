// lib/presentation/request_status/controllers/request_status_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class RequestStatusController extends GetxController {
  final IAuthRepository _authRepository;
  final ISocietyRepository _societyRepository;
  RequestStatusController(this._authRepository, this._societyRepository);

  final society = Rxn<SocietyModel>();
  final status = Rx<JoinRequestStatus>(JoinRequestStatus.pending);
  final isLoading = true.obs;

  String? get _societyId => Get.arguments is String ? Get.arguments as String : null;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final societyId = _societyId;
    final user = _authRepository.currentUser;

    if (societyId == null || user == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final results = await Future.wait([
        _societyRepository.getSocietyById(societyId),
        _societyRepository.getJoinRequestStatus(userId: user.id, societyId: societyId),
      ]);
      society.value = results[0] as SocietyModel?;
      status.value = results[1] as JoinRequestStatus;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => _load();

  void continueToDashboard() {
    // dashboard isn't built yet — SplashController's existing "coming
    // soon" fallback handles this once we route through login again,
    // but for now this is the natural next call once dashboard exists:
    Get.offAllNamed(AppRoutes.dashboard);
  }
}