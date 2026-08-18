// // lib/presentation/request_status/controllers/request_status_controller.dart

// import 'package:get/get.dart';
// import 'package:apart_mate/data/models/property_model.dart';
// import 'package:apart_mate/data/models/society_model.dart';
// import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
// import 'package:apart_mate/domain/repositories/i_property_repository.dart';
// import 'package:apart_mate/domain/repositories/i_society_repository.dart';
// import 'package:apart_mate/routes/app_routes.dart';
// import 'package:apart_mate/core/utils/app_snackbar.dart';

// class requeststatusController extends GetxController {
//   final IAuthRepository _authRepository;
//   final ISocietyRepository _societyRepository;
//   final IPropertyRepository _propertyRepository;
//   requeststatusController(this._authRepository, this._societyRepository, this._propertyRepository);

//   final society = Rxn<SocietyModel>();
//   final property = Rxn<PropertyModel>();
//   final status = Rx<Joinrequeststatus>(Joinrequeststatus.pending);
//   final submittedAt = Rx<DateTime>(DateTime.now());
//   final isLoading = true.obs;

//   String? get _societyId {
//   final args = Get.arguments;
//   if (args is String) return args;
//   if (args is Map) return args['societyId'] as String?;
//   return null;
// }

//   String get requestId {
//     final id = society.value?.id ?? '';
//     final suffix = submittedAt.value.millisecondsSinceEpoch.toString();
//     return 'REQ-${id.toUpperCase()}-${suffix.substring(suffix.length - 6)}';
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     _load();
//   }

// // lib/presentation/request_status/controllers/request_status_controller.dart — only _load() and continueToDashboard() change

//   Future<void> _load() async {
//     final societyId = _societyId;
//     final user = _authRepository.currentUser;

//     if (societyId == null || user == null) {
//       isLoading.value = false;
//       return;
//     }

//     isLoading.value = true;
//     try {
//       final results = await Future.wait([
//         _societyRepository.getSocietyById(societyId),
//         _societyRepository.getJoinRequestInfo(userId: user.id, societyId: societyId),
//         _propertyRepository.getPropertyForUser(user.id), // returns null for tenants — handled by property?.let checks in the view
//       ]);
//       society.value = results[0] as SocietyModel?;
//       final requestInfo = results[1] as JoinRequestInfo;
//       status.value = requestInfo.status;
//       submittedAt.value = requestInfo.submittedAt;
//       property.value = results[2] as PropertyModel?;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//     void continueToDashboard() {
//   // rename later to continueAfterApproval if you want
//   if (status.value != Joinrequeststatus.approved) {
//     AppSnackbar.info(
//       'Not approved yet',
//       'Please wait until the society admin approves your request',
//     );
//     return;
//   }

//   final societyId = _societyId;
//   if (societyId == null || societyId.isEmpty) {
//     AppSnackbar.error('Missing society', 'Please rejoin the society');
//     return;
//   }

//   // ✅ After approval → Property details (not dashboard)
//   Get.offNamed(
//     AppRoutes.propertyDetails,
//     arguments: societyId, // String → society mode (buildings/floors)
//   );
// }

//   Future<void> refresh() => _load();
// }

// lib/presentation/request_status/controllers/request_status_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/core/session/app_session.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class requeststatusController extends GetxController {
  final IAuthRepository _authRepository;
  final ISocietyRepository _societyRepository;
  final IPropertyRepository _propertyRepository;

  requeststatusController(
    this._authRepository,
    this._societyRepository,
    this._propertyRepository,
  );

  final society = Rxn<SocietyModel>();
  final property = Rxn<PropertyModel>();
  final status = Rx<Joinrequeststatus>(Joinrequeststatus.pending);
  final submittedAt = Rx<DateTime>(DateTime.now());
  final isLoading = true.obs;

  String? get _societyId {
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) return args;
    if (args is Map) {
      final id = args['societyId'];
      if (id is String && id.isNotEmpty) return id;
    }
    return null;
  }

  String get requestId {
    final id = society.value?.id ?? _societyId ?? '';
    final suffix = submittedAt.value.millisecondsSinceEpoch.toString();
    final tail =
        suffix.length >= 6 ? suffix.substring(suffix.length - 6) : suffix;
    return 'REQ-${id.toUpperCase()}-$tail';
  }

  bool get isApproved => status.value == Joinrequeststatus.approved;
  bool get isPending => status.value == Joinrequeststatus.pending;
  bool get isRejected => status.value == Joinrequeststatus.rejected;

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
        _societyRepository.getJoinRequestInfo(
          userId: user.id,
          societyId: societyId,
        ),
        _propertyRepository.getPropertyForUser(user.id),
      ]);

      society.value = results[0] as SocietyModel?;
      final requestInfo = results[1] as JoinRequestInfo;
      status.value = requestInfo.status;
      submittedAt.value = requestInfo.submittedAt;
      property.value = results[2] as PropertyModel?;

      // If already approved and user opens this screen again, optional auto-advance
      // is handled by routeOwner() on splash — here we only enable Continue.
      if (status.value == Joinrequeststatus.approved &&
          Get.isRegistered<AppSession>()) {
        final session = Get.find<AppSession>();
        if (!session.hasOwnerRole.value) {
          session.registerOwner();
        }
      }
    } catch (e) {
      AppSnackbar.error('Could not load status', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh / Refresh button — call after Pro accepts
  Future<void> refresh() => _load();

  /// Continue only when Pro has approved → Property details
  void continueToDashboard() {
    if (status.value != Joinrequeststatus.approved) {
      AppSnackbar.info(
        'Not approved yet',
        'Please wait until the society admin approves your request',
      );
      return;
    }

    final societyId = _societyId ?? society.value?.id;
    if (societyId == null || societyId.isEmpty) {
      AppSnackbar.error('Missing society', 'Please rejoin the society');
      return;
    }

    if (Get.isRegistered<AppSession>()) {
      Get.find<AppSession>().registerOwner();
    }

    // Approved → property details (buildings/floors for this society)
    Get.offAllNamed(
      AppRoutes.propertyDetails,
      arguments: societyId,
    );
  }
  
}