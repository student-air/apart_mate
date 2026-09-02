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
  final status = Rx<Joinrequeststatus>(Joinrequeststatus.approved);
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

  /// 'staff' when employee join-code path; otherwise owner (or null).
  String? get _requestType {
    final args = Get.arguments;
    if (args is Map) {
      final t = args['type'];
      if (t is String && t.isNotEmpty) return t.toLowerCase();
    }
    return null;
  }

  bool get isStaffRequest => _requestType == 'staff';

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

      // Owner path only: mark owner role when already approved
      if (!isStaffRequest &&
          status.value == Joinrequeststatus.approved &&
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

  /// Pull-to-refresh — call after Pro accepts
  Future<void> refresh() => _load();

  /// Continue only when approved.
  /// Staff → employee dashboard | Owner → property details
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

    // Employee / staff request → employee dashboard
    if (isStaffRequest) {
      Get.offAllNamed(AppRoutes.employeeDashboard);
      return;
    }

    // Owner request → register owner + property details
    if (Get.isRegistered<AppSession>()) {
      Get.find<AppSession>().registerOwner();
    }

    Get.offAllNamed(
      AppRoutes.propertyDetails,
      arguments: societyId,
    );
  }
}