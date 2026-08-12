// lib/presentation/manage_properties/controllers/manage_properties_controller.dart

import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class ManagePropertiesController extends GetxController {
  late final DashboardController _dashboard;

  final isLoading = false.obs;

  SocietyModel? get society => _dashboard.society.value;

  String get societyName => society?.name ?? '';

  List<PropertyModel> get properties =>
      _dashboard.propertiesInCurrentSociety;

  PropertyModel? get selectedProperty => _dashboard.property.value;

  @override
  void onInit() {
    super.onInit();
    _dashboard = Get.find<DashboardController>();
  }

  void selectProperty(PropertyModel property) {
    _dashboard.selectProperty(property);
  }

  void editProperty(PropertyModel property) {
    selectProperty(property);
    Get.toNamed(AppRoutes.propertyDetails, arguments: property);
  }

  void addProperty() {
    final societyId = society?.id;
    if (societyId == null || societyId.isEmpty) {
      // No society context — shouldn't happen from this screen
      Get.toNamed(AppRoutes.propertyDetails);
      return;
    }
    // Pass societyId → society form (building, floor, flat number)
    Get.toNamed(AppRoutes.propertyDetails, arguments: societyId);
  }

Future<void> deleteProperty(PropertyModel property) async {
  final confirmed = await Get.dialog<bool>(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trash icon in circle
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2), // light red
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 26,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              'Delete property?',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              'This will permanently remove "Flat ${property.flatNumber}" from the list.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Red Delete button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: Text(
                  'Delete',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Cancel
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (confirmed != true) return;

  isLoading.value = true;
  try {
    await _dashboard.deleteProperty(property);

    AppSnackbar.info(
      'Deleted',
      'Flat ${property.flatNumber} has been permanently removed',
    );
  } catch (e) {
    AppSnackbar.error(
      'Error',
      'Could not delete property. Please try again.',
    );
  } finally {
    isLoading.value = false;
  }
}

Future<void> refresh() async {
  isLoading.value = true;
  try {
    await _dashboard.refresh();
  } finally {
    isLoading.value = false;
  }
}
}