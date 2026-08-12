// lib/presentation/property_details/controllers/property_details_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class PropertyDetailsController extends GetxController {
  final IAuthRepository _authRepository;
  final IPropertyRepository _propertyRepository;
  PropertyDetailsController(this._authRepository, this._propertyRepository);

  // ── Society mode lists ──────────────────────────────────────
  static const buildings = ['Block A', 'Block B', 'Block C'];
  static const floors = [
    'Ground',
    '1st Floor',
    '2nd Floor',
    '3rd Floor',
    '4th Floor',
    '5th Floor',
  ];

  // ── Independent mode lists ──────────────────────────────────
  static const houseTypes = [
    'Independent House',
    'Bungalow',
    'Villa',
    'Townhouse',
  ];

  // Shared lists
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

  // ── Controllers ─────────────────────────────────────────────
  final flatNumberCtrl = TextEditingController(); // House Name in independent mode
  final addressCtrl = TextEditingController(); // independent only
  final areaCtrl = TextEditingController();
  final bathroomsCtrl = TextEditingController();

  // ── Observables ─────────────────────────────────────────────
  final selectedBuilding = RxnString();
  final selectedFloor = RxnString();
  final selectedHouseType = RxnString(); // independent only
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

  final isLoading = false.obs;

  /// Existing property when opened from Edit. Null = create flow.
  PropertyModel? existingProperty;

  bool get isEditMode => existingProperty != null;

  /// true = Independent Owner (no society)
  bool get isIndependent {
    if (isEditMode) {
      return existingProperty!.societyId.isEmpty;
    }
    final args = Get.arguments;
    // We pass null from continueAsIndependentOwner()
    return args == null;
  }

  String get headerTitle =>
      isEditMode ? 'Edit Property' : 'Property Details';

  String get headerSubtitle {
    if (isIndependent) {
      final name = flatNumberCtrl.text.trim();
      final type = selectedHouseType.value;
      if (name.isEmpty && type == null) return 'Tell us about your house';
      final parts = [
        if (name.isNotEmpty) name,
        if (type != null) type,
      ];
      return parts.join(' · ');
    }

    final flat = flatNumberCtrl.text.trim();
    final building = selectedBuilding.value;
    if (flat.isEmpty && building == null) return 'Tell us about your property';
    final parts = [
      if (flat.isNotEmpty) 'Flat $flat',
      if (building != null) building,
    ];
    return parts.join(' · ');
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PropertyModel) {
      existingProperty = args;
      _prefillFrom(args);
    }
  }

  void _prefillFrom(PropertyModel p) {
    flatNumberCtrl.text = p.flatNumber;
    areaCtrl.text = p.areaSqFt;
    bathroomsCtrl.text = p.bathrooms;

    if (p.societyId.isEmpty) {
      // independent
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
  }

  // ── Validation ──────────────────────────────────────────────
  bool validateStep(int step) {
    if (isIndependent) {
      return _validateIndependent(step);
    }
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
      case 2:
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
        // Address not required when editing (may not be stored on model)
        if (addressCtrl.text.trim().isEmpty && !isEditMode) {
          AppSnackbar.error('Missing info', 'Please enter address');
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
      case 2:
        return true;
      default:
        return true;
    }
  }

  // ── Save ────────────────────────────────────────────────────
  Future<void> saveAndContinue() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final societyId = isEditMode
        ? existingProperty!.societyId
        : (isIndependent
            ? ''
            : (Get.arguments is String ? Get.arguments as String : ''));

    isLoading.value = true;
    try {
      await _propertyRepository.saveProperty(
        PropertyModel(
          id: isEditMode
              ? existingProperty!.id
              : 'property_${DateTime.now().millisecondsSinceEpoch}',
          userId: user.id,
          societyId: societyId,
          building: isIndependent
              ? (selectedHouseType.value ?? '')
              : selectedBuilding.value!,
          floor: isIndependent ? '' : selectedFloor.value!,
          flatNumber: flatNumberCtrl.text.trim(),
          isOccupied: isOccupied.value,
          occupiedBy: occupiedBy.value,
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
          createdAt:
              isEditMode ? existingProperty!.createdAt : DateTime.now(),
        ),
      );

      if (isEditMode) {
        AppSnackbar.success('Updated', 'Property details saved');
        Get.back();
        if (Get.isRegistered<DashboardController>()) {
          await Get.find<DashboardController>().refresh();
        }
      } else if (isIndependent) {
        // Independent owners go straight to dashboard (no approval needed)
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offNamed(AppRoutes.requeststatus, arguments: societyId);
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
    super.onClose();
  }
}