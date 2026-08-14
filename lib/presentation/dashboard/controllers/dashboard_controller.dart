// lib/presentation/dashboard/controllers/dashboard_controller.dart

import 'package:apart_mate/core/session/app_session.dart';
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

  DashboardController(
    this._authRepository,
    this._societyRepository,
    this._propertyRepository,
  );

  final society = Rxn<SocietyModel>();
  final property = Rxn<PropertyModel>();
  final properties = <PropertyModel>[].obs;
  final societies = <SocietyModel>[].obs;

  final requestApproved = false.obs;
  final updates = <DashboardUpdateItem>[].obs;
  final isLoading = true.obs;

  String get userName => _authRepository.currentUser?.fullName ?? '';
  String get userRole => _authRepository.currentUser?.role ?? '';
  String get roleLabel =>
      userRole.isEmpty ? '' : userRole[0].toUpperCase() + userRole.substring(1);
  bool get isTenant => userRole == 'tenant';

  /// Properties belonging to the currently selected society
  List<PropertyModel> get propertiesInCurrentSociety {
    final sid = society.value?.id;
    if (sid == null) return [];
    return properties.where((p) => p.societyId == sid).toList();
  }

  bool get hasMultipleSocieties => societies.length > 1;
  bool get hasMultiplePropertiesInSociety =>
      propertiesInCurrentSociety.length > 1;

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
      final fetchedProperties =
          await _propertyRepository.getPropertiesForUser(user.id);
      properties.value = fetchedProperties;

      // Unique society IDs from properties
      final societyIds = fetchedProperties.map((p) => p.societyId).toSet();

      // Also include any society the user joined even without property
      final joinedSocietyId =
          await _societyRepository.getSocietyIdForUser(user.id);
      if (joinedSocietyId != null) societyIds.add(joinedSocietyId);

      final loadedSocieties = <SocietyModel>[];
      for (final id in societyIds) {
        final s = await _societyRepository.getSocietyById(id);
        if (s != null) loadedSocieties.add(s);
      }
      societies.value = loadedSocieties;

      // Restore selection or pick first
      final currentPropId = property.value?.id;
      final currentSocId = society.value?.id;

      PropertyModel? selectedProp = fetchedProperties
          .cast<PropertyModel?>()
          .firstWhere((p) => p?.id == currentPropId, orElse: () => null);

      SocietyModel? selectedSoc = loadedSocieties
          .cast<SocietyModel?>()
          .firstWhere((s) => s?.id == currentSocId, orElse: () => null);

      // Defaults
      if (selectedProp == null && fetchedProperties.isNotEmpty) {
        selectedProp = fetchedProperties.first;
      }
      if (selectedSoc == null) {
        if (selectedProp != null) {
          selectedSoc = loadedSocieties
              .cast<SocietyModel?>()
              .firstWhere(
                (s) => s?.id == selectedProp!.societyId,
                orElse: () => loadedSocieties.isEmpty ? null : loadedSocieties.first,
              );
        } else if (loadedSocieties.isNotEmpty) {
          selectedSoc = loadedSocieties.first;
        }
      }

      // Align property with selected society
      if (selectedSoc != null && selectedProp != null) {
        if (selectedProp.societyId != selectedSoc.id) {
          final inSoc = fetchedProperties
              .where((p) => p.societyId == selectedSoc!.id)
              .toList();
          selectedProp = inSoc.isEmpty ? null : inSoc.first;
        }
      }

      property.value = selectedProp;
      society.value = selectedSoc;

      await _loadApprovalAndUpdates(user.id, selectedSoc, fetchedProperties);
    } finally {
      isLoading.value = false;
    }

    final session = Get.find<AppSession>();

if (society.value != null && !session.hasOwnerRole.value) {
  session.registerOwner();
}
  }

  Future<void> _loadApprovalAndUpdates(
    String userId,
    SocietyModel? selectedSoc,
    List<PropertyModel> allProps,
  ) async {
    bool approved = false;
    final events = <DashboardUpdateItem>[];

    if (selectedSoc != null) {
      final requestInfo = await _societyRepository.getJoinRequestInfo(
        userId: userId,
        societyId: selectedSoc.id,
      );
      approved = requestInfo.status == JoinRequestStatus.approved;

      events.add(DashboardUpdateItem(
        title: 'Request to join ${selectedSoc.name} submitted',
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

    for (final p in allProps) {
      events.add(DashboardUpdateItem(
        title: 'Property details for Flat ${p.flatNumber} submitted',
        postedAt: p.createdAt,
        type: DashboardUpdateType.propertyUpdate,
      ));
    }

    events.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    requestApproved.value = approved;
    updates.value = events;
  }

  /// Switch society (top dropdown)
  Future<void> selectSociety(SocietyModel selected) async {
    if (society.value?.id == selected.id) return;

    society.value = selected;

    // Pick first property in this society (if any)
    final inSoc =
        properties.where((p) => p.societyId == selected.id).toList();
    property.value = inSoc.isEmpty ? null : inSoc.first;

    final user = _authRepository.currentUser;
    if (user != null) {
      await _loadApprovalAndUpdates(user.id, selected, properties);
    }
  }

  Future<void> deleteProperty(PropertyModel property) async {
  await _propertyRepository.deleteProperty(property.id);

  // If the deleted property was the selected one, clear it
  if (this.property.value?.id == property.id) {
    this.property.value = null;
  }

  // Refresh so lists update
  await loadDashboard();
}

  /// Switch property within current society (property card dropdown)
  void selectProperty(PropertyModel selected) {
    if (property.value?.id == selected.id) return;
    // Only allow properties of the current society
    if (society.value != null && selected.societyId != society.value!.id) {
      return;
    }
    property.value = selected;
  }

  Future<void> releaseProperty(PropertyModel property) async {
  await _propertyRepository.releaseProperty(property.id);
  await refresh();
}

  Future<void> refresh() => loadDashboard();
}

class JoinRequestStatus {
  static final Object approved = Object();
}