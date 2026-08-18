// lib/presentation/request_status/controllers/request_status_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';

class requeststatusController extends GetxController {
  final IAuthRepository _authRepository;
  final ISocietyRepository _societyRepository;
  final IPropertyRepository _propertyRepository;
  requeststatusController(this._authRepository, this._societyRepository, this._propertyRepository);

  final society = Rxn<SocietyModel>();
  final property = Rxn<PropertyModel>();
  final status = Rx<Joinrequeststatus>(Joinrequeststatus.pending);
  final submittedAt = Rx<DateTime>(DateTime.now());
  final isLoading = true.obs;

  String? get _societyId {
  final args = Get.arguments;
  if (args is String) return args;
  if (args is Map) return args['societyId'] as String?;
  return null;
}

  String get requestId {
    final id = society.value?.id ?? '';
    final suffix = submittedAt.value.millisecondsSinceEpoch.toString();
    return 'REQ-${id.toUpperCase()}-${suffix.substring(suffix.length - 6)}';
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

// lib/presentation/request_status/controllers/request_status_controller.dart — only _load() and continueToDashboard() change

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
        _societyRepository.getJoinRequestInfo(userId: user.id, societyId: societyId),
        _propertyRepository.getPropertyForUser(user.id), // returns null for tenants — handled by property?.let checks in the view
      ]);
      society.value = results[0] as SocietyModel?;
      final requestInfo = results[1] as JoinRequestInfo;
      status.value = requestInfo.status;
      submittedAt.value = requestInfo.submittedAt;
      property.value = results[2] as PropertyModel?;
    } finally {
      isLoading.value = false;
    }
  }

    void continueToDashboard() {
  // rename later to continueAfterApproval if you want
  if (status.value != Joinrequeststatus.approved) {
    AppSnackbar.info(
      'Not approved yet',
      'Please wait until the society admin approves your request',
    );
    return;
  }

  final societyId = _societyId;
  if (societyId == null || societyId.isEmpty) {
    AppSnackbar.error('Missing society', 'Please rejoin the society');
    return;
  }

  // ✅ After approval → Property details (not dashboard)
  Get.offNamed(
    AppRoutes.propertyDetails,
    arguments: societyId, // String → society mode (buildings/floors)
  );
}

  Future<void> refresh() => _load();
}