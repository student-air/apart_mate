// lib/presentation/property_details/controllers/property_details_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/utils/property_unit_key.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/domain/repositories/i_society_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class PropertyDetailsController extends GetxController {
  final IAuthRepository _authRepository;
  final IPropertyRepository _propertyRepository;

  PropertyDetailsController(this._authRepository, this._propertyRepository);

  // ── Buildings / floors from Pro (Firestore) ─────────────────
  final buildings = <SocietyBuildingInfo>[].obs;
  final buildingOptions = <String>[].obs;
  final floorOptions = <String>[].obs;

  // ── Independent (not used for now; kept for edit of old data) ─
  static const houseTypes = [
    'Independent House',
    'Bungalow',
    'Villa',
    'Townhouse',
  ];

  static const propertyTypes = ['Apartment', 'House', 'Office'];
  static const flatTypes = ['1 Bed', '2 Bed', '3 Bed', '4 Bed', 'Studio'];
  static const meterTypes = ['Wapda', 'Society', 'WAPDA Meter'];
  static const waterConnectionTypes = [
    'Municipal',
    'Borewell',
    'Society Supply',
  ];
  static const furnishingTypes = [
    'Furnished',
    'Semi Furnished',
    'Unfurnished',
  ];

  final flatNumberCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final bathroomsCtrl = TextEditingController();
  final maintenanceAmountCtrl = TextEditingController();

  final selectedBuilding = RxnString();
  final selectedFloor = RxnString();
  final selectedHouseType = RxnString();
  final isOccupied = true.obs;
  final occupiedBy = 'owner'.obs;
  final selectedPropertyType = RxnString();
  final selectedFlatType = RxnString();
  final hasBalcony = true.obs;
  final hasElectricity = true.obs;
  final hasGas = true.obs;
  final selectedMeterType = RxnString();
  final selectedWaterConnection = RxnString();
  final selectedFurnishing = RxnString();
  final maintenanceBy = 'property_owner'.obs;
  final isLoading = false.obs;
  final isLoadingBuildings = false.obs;

  PropertyModel? existingProperty;

  bool get isEditMode => existingProperty != null;

  /// Independent only when no society id (legacy / not implemented for create).
  bool get isIndependent {
    if (isEditMode) return existingProperty!.societyId.isEmpty;
    return _resolveSocietyId() == null;
  }

  String? _resolveSocietyId() {
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) return args;
    if (args is Map && args['societyId'] is String) {
      final id = args['societyId'] as String;
      if (id.isNotEmpty) return id;
    }
    if (Get.isRegistered<DashboardController>()) {
      final id = Get.find<DashboardController>().society.value?.id;
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  String? get _societyId => isIndependent ? null : _resolveSocietyId();

  String get headerTitle => isEditMode ? 'Edit Property' : 'Property Details';

  String get headerSubtitle {
    if (isIndependent) {
      final name = flatNumberCtrl.text.trim();
      final type = selectedHouseType.value;
      if (name.isEmpty && type == null) return 'Tell us about your house';
      return [if (name.isNotEmpty) name, if (type != null) type].join(' · ');
    }
    final flat = flatNumberCtrl.text.trim();
    final building = selectedBuilding.value;
    if (flat.isEmpty && building == null) return 'Tell us about your property';
    return [
      if (flat.isNotEmpty) 'Flat $flat',
      if (building != null) building,
    ].join(' · ');
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PropertyModel) {
      existingProperty = args;
      _prefillFrom(args);
    }
    if (!isIndependent) {
      loadBuildings();
    }
  }

  void _prefillFrom(PropertyModel p) {
    flatNumberCtrl.text = p.flatNumber;
    areaCtrl.text = p.areaSqFt;
    bathroomsCtrl.text = p.bathrooms;
    maintenanceAmountCtrl.text = p.maintenanceAmount;

    if (p.societyId.isEmpty) {
      selectedHouseType.value = p.building.isNotEmpty ? p.building : null;
    } else {
      selectedBuilding.value = p.building.isNotEmpty ? p.building : null;
      selectedFloor.value = p.floor.isNotEmpty ? p.floor : null;
    }

    isOccupied.value = p.isOccupied;
    occupiedBy.value = p.occupiedBy.isNotEmpty ? p.occupiedBy : 'owner';
    selectedPropertyType.value =
        p.propertyType.isNotEmpty ? p.propertyType : null;
    selectedFlatType.value = p.flatType.isNotEmpty ? p.flatType : null;
    hasBalcony.value = p.hasBalcony;
    hasElectricity.value = p.hasElectricity;
    hasGas.value = p.hasGas;
    selectedMeterType.value = p.meterType.isNotEmpty ? p.meterType : null;
    selectedWaterConnection.value =
        p.waterConnection.isNotEmpty ? p.waterConnection : null;
    selectedFurnishing.value =
        p.furnishing.isNotEmpty ? p.furnishing : null;
    maintenanceBy.value =
        p.maintenanceBy.isNotEmpty ? p.maintenanceBy : 'property_owner';
  }

  Future<void> loadBuildings() async {
    final societyId = _societyId;
    if (societyId == null) return;

    isLoadingBuildings.value = true;
    try {
      final list =
          await Get.find<ISocietyRepository>().getBuildings(societyId);
      buildings.assignAll(list);
      buildingOptions.assignAll(list.map((b) => b.name));

      // If editing, rebuild floor list for the current building
      final current = selectedBuilding.value;
      if (current != null) {
        await onBuildingSelected(current);
      } else {
        floorOptions.clear();
      }
    } catch (e) {
      AppSnackbar.error('Buildings', 'Could not load buildings');
      buildings.clear();
      buildingOptions.clear();
      floorOptions.clear();
    } finally {
      isLoadingBuildings.value = false;
    }
  }

  /// MUST be used by the Building dropdown (loads floors).
  Future<void> onBuildingSelected(String? name) async {
    selectedBuilding.value = name;
    selectedFloor.value = null;
    floorOptions.clear();

    if (name == null) return;

    final matches = buildings.where((b) => b.name == name).toList();
    if (matches.isEmpty) return;

    final building = matches.first;
    final societyId = _societyId;
    if (societyId == null) return;

    // Prefer totalFloors already on the building; otherwise fetch
    var total = building.totalFloors;
    if (total <= 0) {
      total = await Get.find<ISocietyRepository>()
          .getFloorCountForBuilding(societyId, building.id);
    }

    floorOptions.assignAll(_buildFloorLabels(total));
  }

  List<String> _buildFloorLabels(int totalFloors) {
    if (totalFloors <= 0) {
      return const [
        'Ground',
        '1st Floor',
        '2nd Floor',
        '3rd Floor',
        '4th Floor',
        '5th Floor',
      ];
    }
    final labels = <String>['Ground'];
    for (var i = 1; i < totalFloors; i++) {
      labels.add(_ordinalFloor(i));
    }
    return labels;
  }

  String _ordinalFloor(int n) {
    if (n == 1) return '1st Floor';
    if (n == 2) return '2nd Floor';
    if (n == 3) return '3rd Floor';
    return '${n}th Floor';
  }

  void setMaintenanceBy(String value) {
    maintenanceBy.value = value;
  }

  bool validateStep(int step) {
    if (isIndependent) return _validateIndependent(step);
    return _validateSociety(step);
  }

  bool _validateSociety(int step) {
    switch (step) {
      case 0:
        if (selectedBuilding.value == null) {
          AppSnackbar.error('Missing info', 'Please select a building');
          return false;
        }
        if (selectedFloor.value == null) {
          AppSnackbar.error('Missing info', 'Please select a floor');
          return false;
        }
        if (flatNumberCtrl.text.trim().isEmpty) {
          AppSnackbar.error('Missing info', 'Please enter your flat number');
          return false;
        }
        return true;
      case 1:
        if (selectedPropertyType.value == null) {
          AppSnackbar.error('Missing info', 'Please select a property type');
          return false;
        }
        if (selectedFlatType.value == null) {
          AppSnackbar.error('Missing info', 'Please select a flat type');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  bool _validateIndependent(int step) {
    switch (step) {
      case 0:
        if (flatNumberCtrl.text.trim().isEmpty) {
          AppSnackbar.error('Missing info', 'Please enter house name');
          return false;
        }
        if (selectedHouseType.value == null) {
          AppSnackbar.error('Missing info', 'Please select house type');
          return false;
        }
        return true;
      case 1:
        if (selectedPropertyType.value == null) {
          AppSnackbar.error('Missing info', 'Please select a property type');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

    Future<void> saveAndContinue() async {
    // Always use Firebase Auth uid (must match Firestore rules)
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    final uid = authUser.uid;

    // Resolve society id (create flow)
    String societyId;
    if (isEditMode) {
      societyId = existingProperty!.societyId;
    } else if (isIndependent) {
      societyId = '';
    } else {
      societyId = _societyId ??
          (Get.arguments is String ? Get.arguments as String : '') ;
      if (societyId.isEmpty &&
          Get.isRegistered<DashboardController>()) {
        societyId =
            Get.find<DashboardController>().society.value?.id ?? '';
      }
    }

    if (!isIndependent && societyId.isEmpty) {
      AppSnackbar.error(
        'No society',
        'Join a society before adding a property',
      );
      return;
    }

    final building = isIndependent
        ? (selectedHouseType.value ?? '')
        : (selectedBuilding.value ?? '');
    final floor = isIndependent ? '' : (selectedFloor.value ?? '');
    final flatNumber = flatNumberCtrl.text.trim();

    if (!isIndependent) {
      if (building.isEmpty) {
        AppSnackbar.error('Missing info', 'Please select a building');
        return;
      }
      if (floor.isEmpty) {
        AppSnackbar.error('Missing info', 'Please select a floor');
        return;
      }
      if (flatNumber.isEmpty) {
        AppSnackbar.error('Missing info', 'Please enter your flat number');
        return;
      }
    }

    isLoading.value = true;
    try {
      // Uniqueness check (create only, society units)
      if (!isEditMode && !isIndependent) {
        final unitKey = buildPropertyUnitKey(
          societyId: societyId,
          building: building,
          floor: floor,
          flatNumber: flatNumber,
        );

        final existingClaim =
            await _propertyRepository.findActiveClaimByUnitKey(unitKey);

        if (existingClaim != null && existingClaim.userId != uid) {
          AppSnackbar.error(
            'Already registered',
            'This property is already registered to another user',
          );
          return;
        }
      }

      final property = PropertyModel(
        id: isEditMode
            ? existingProperty!.id
            : 'property_${DateTime.now().millisecondsSinceEpoch}',
        userId: uid, // MUST be Firebase Auth uid
        societyId: societyId,
        building: building,
        floor: floor,
        flatNumber: flatNumber,
        isOccupied: isEditMode ? existingProperty!.isOccupied : false,
        occupiedBy: isEditMode ? existingProperty!.occupiedBy : '',
        propertyType:
            selectedPropertyType.value ?? (isIndependent ? 'House' : ''),
        areaSqFt: areaCtrl.text.trim(),
        bathrooms: bathroomsCtrl.text.trim(),
        flatType: selectedFlatType.value ?? '',
        hasBalcony: hasBalcony.value,
        hasElectricity: hasElectricity.value,
        hasGas: hasGas.value,
        meterType: selectedMeterType.value ?? '',
        waterConnection: selectedWaterConnection.value ?? '',
        furnishing: selectedFurnishing.value ?? '',
        createdAt: isEditMode ? existingProperty!.createdAt : DateTime.now(),
        claimStatus: isEditMode ? existingProperty!.claimStatus : 'active',
        maintenanceBy: maintenanceBy.value,
        maintenanceAmount: maintenanceBy.value == 'property_owner'
            ? maintenanceAmountCtrl.text.trim()
            : '',
      );

      await _propertyRepository.saveProperty(property);

      AppSnackbar.success(
        isEditMode ? 'Updated' : 'Saved',
        isEditMode
            ? 'Property details updated'
            : 'Property added successfully',
      );

      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refresh();
      }

      if (isEditMode) {
        Get.offNamed(AppRoutes.manageProperties);
      } else {
        // Owner flow: after add property → dashboard (not request status)
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('permission-denied') ||
          msg.contains('PERMISSION_DENIED')) {
        AppSnackbar.error(
          'Save failed',
          'Permission denied. Check Firestore rules and that you are signed in.',
        );
      } else {
        AppSnackbar.error('Save failed', msg);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() => Get.back();

  @override
  void onClose() {
    flatNumberCtrl.dispose();
    addressCtrl.dispose();
    areaCtrl.dispose();
    bathroomsCtrl.dispose();
    maintenanceAmountCtrl.dispose();
    super.onClose();
  }
}