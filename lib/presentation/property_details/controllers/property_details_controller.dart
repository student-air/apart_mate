// lib/presentation/property_details/controllers/property_details_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/domain/repositories/i_auth_repository.dart';
import 'package:apart_mate/domain/repositories/i_property_repository.dart';
import 'package:apart_mate/routes/app_routes.dart';

class PropertyDetailsController extends GetxController {
  final IAuthRepository _authRepository;
  final IPropertyRepository _propertyRepository;
  PropertyDetailsController(this._authRepository, this._propertyRepository);

  static const buildings = ['Block A', 'Block B', 'Block C'];
  static const floors = ['Ground', '1st Floor', '2nd Floor', '3rd Floor', '4th Floor', '5th Floor'];
  static const propertyTypes = ['Apartment', 'House', 'Office'];
  static const flatTypes = ['1 Bed', '2 Bed', '3 Bed', '4 Bed', 'Studio'];
  static const meterTypes = ['Wapda', 'Society'];
  static const waterConnectionTypes = ['Municipal', 'Borewell', 'Society Supply'];
  static const furnishingTypes = ['Furnished', 'Semi Furnished', 'Unfurnished'];

  final flatNumberCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final bathroomsCtrl = TextEditingController();

  final selectedBuilding = RxnString();
  final selectedFloor = RxnString();
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

  /// Live preview shown in the header, e.g. "Flat A-203 · Block A" —
  /// falls back to a generic prompt until enough fields are filled in.
  String get headerSubtitle {
    final flat = flatNumberCtrl.text.trim();
    final building = selectedBuilding.value;
    if (flat.isEmpty && building == null) {
      return 'Tell us about your property';
    }
    final parts = [
      if (flat.isNotEmpty) 'Flat $flat',
      if (building != null) building,
    ];
    return parts.join(' · ');
  }

  Future<void> saveAndContinue() async {
    if (selectedBuilding.value == null) {
      AppSnackbar.error('Missing info', 'Please select a building');
      return;
    }
    if (selectedFloor.value == null) {
      AppSnackbar.error('Missing info', 'Please select a floor');
      return;
    }
    if (flatNumberCtrl.text.trim().isEmpty) {
      AppSnackbar.error('Missing info', 'Please enter your flat number');
      return;
    }
    if (selectedPropertyType.value == null) {
      AppSnackbar.error('Missing info', 'Please select a property type');
      return;
    }
    if (selectedFlatType.value == null) {
      AppSnackbar.error('Missing info', 'Please select a flat type');
      return;
    }

    final user = _authRepository.currentUser;
    if (user == null) {
      AppSnackbar.error('Not signed in', 'Please sign in again');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final societyId = Get.arguments is String ? Get.arguments as String : '';

    isLoading.value = true;
    try {
      await _propertyRepository.saveProperty(
        PropertyModel(
          id: 'property_${DateTime.now().millisecondsSinceEpoch}',
          userId: user.id,
          societyId: societyId,
          building: selectedBuilding.value!,
          floor: selectedFloor.value!,
          flatNumber: flatNumberCtrl.text.trim(),
          isOccupied: isOccupied.value,
          occupiedBy: occupiedBy.value,
          propertyType: selectedPropertyType.value!,
          areaSqFt: areaCtrl.text.trim(),
          bathrooms: bathroomsCtrl.text.trim(),
          flatType: selectedFlatType.value!,
          hasBalcony: hasBalcony.value,
          hasElectricity: hasElectricity.value,
          hasGas: hasGas.value,
          meterType: selectedMeterType.value ?? '',
          waterConnection: selectedWaterConnection.value ?? '',
          furnishing: selectedFurnishing.value ?? '',
        ),
      );
      Get.offNamed(AppRoutes.requestStatus, arguments: societyId);
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() => Get.back();

  @override
  void onClose() {
    flatNumberCtrl.dispose();
    areaCtrl.dispose();
    bathroomsCtrl.dispose();
    super.onClose();
  }
}