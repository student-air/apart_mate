// lib/presentation/manage_properties/controllers/manage_properties_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
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
      Get.toNamed(AppRoutes.propertyDetails);
      return;
    }
    Get.toNamed(AppRoutes.propertyDetails, arguments: societyId);
  }

  Future<void> markAsSold(PropertyModel property) async {
    if (property.isOccupied &&
        property.occupiedBy.toLowerCase() == 'tenant') {
      AppSnackbar.error(
        'Cannot mark as sold',
        'A tenant is still linked to this unit. Remove the tenant first.',
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.pastelRedBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.sell_rounded,
                  size: 26,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Mark as sold?',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'This will release your claim on Flat ${property.flatNumber}. '
                'This action cannot be undone. Another user may register this property.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.textOnDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Agree',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
      await _dashboard.releaseProperty(property);
      AppSnackbar.success(
        'Released',
        'Flat ${property.flatNumber} is no longer claimed by you',
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('TENANT_LINKED')) {
        AppSnackbar.error(
          'Cannot mark as sold',
          'A tenant is still linked to this unit',
        );
      } else {
        AppSnackbar.error('Failed', 'Could not release property');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProperty(PropertyModel property) async {
    final confirmed = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.pastelRedBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 26,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Delete property?',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'This will permanently remove "Flat ${property.flatNumber}" from the list.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.textOnDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.textOnDark,
                  ),
                  label: Text(
                    'Delete',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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