// lib/presentation/dashboard/controllers/dashboard_controller.dart

import 'package:get/get.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';

class DashboardUpdateItem {
  final String title;
  final DateTime postedAt;
  final DashboardUpdateType type;

  const DashboardUpdateItem({
    required this.title,
    required this.postedAt,
    required this.type,
  });
}

enum DashboardUpdateType { announcement, propertyUpdate, verification }

class DashboardController extends GetxController {
  final IAuthRepository _authRepository;
  final ISocietyRepository _societyRepository;
  final IPropertyRepository _propertyRepository;
  DashboardController(this._authRepository, this._societyRepository, this._propertyRepository);

  final society = Rxn<SocietyModel>();
  final property = Rxn<PropertyModel>();
  final requestApproved = false.obs;
  final updates = <DashboardUpdateItem>[].obs;
  final isLoading = true.obs;

  String get userName => _authRepository.currentUser?.fullName ?? '';
  String get userRole => _authRepository.currentUser?.role ?? '';
  String get roleLabel => userRole.isEmpty ? '' : userRole[0].toUpperCase() + userRole.substring(1);

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      final societyId = await _societyRepository.getSocietyIdForUser(user.id);
      final fetchedProperty = await _propertyRepository.getPropertyForUser(user.id);

      SocietyModel? fetchedSociety;
      bool approved = false;
      final events = <DashboardUpdateItem>[];

      if (societyId != null) {
        fetchedSociety = await _societyRepository.getSocietyById(societyId);
        final requestInfo = await _societyRepository.getJoinRequestInfo(userId: user.id, societyId: societyId);
        approved = requestInfo.status == JoinRequestStatus.approved;

        events.add(DashboardUpdateItem(
          title: 'Request to join ${fetchedSociety?.name ?? "society"} submitted',
          postedAt: requestInfo.submittedAt,
          type: DashboardUpdateType.announcement,
        ));
        if (approved) {
          events.add(DashboardUpdateItem(
            title: 'Membership request approved',
            postedAt: requestInfo.submittedAt,
            type: DashboardUpdateType.verification,
          ));
        }
      }

      if (fetchedProperty != null) {
        events.add(DashboardUpdateItem(
          title: 'Property details for Flat ${fetchedProperty.flatNumber} submitted',
          postedAt: fetchedProperty.createdAt,
          type: DashboardUpdateType.propertyUpdate,
        ));
      }

      events.sort((a, b) => b.postedAt.compareTo(a.postedAt));

      society.value = fetchedSociety;
      property.value = fetchedProperty;
      requestApproved.value = approved;
      updates.value = events;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadDashboard();
}