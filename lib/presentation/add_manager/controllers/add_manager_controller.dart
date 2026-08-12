import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_snackbar.dart';
import 'package:apart_mate/core/widgets/app_button.dart';
import 'package:apart_mate/data/models/manager_model.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/data/models/society_model.dart';
import 'package:apart_mate/data/repositories/local_manager_repository.dart';
import 'package:apart_mate/domain/repositories/i_manager_repository.dart';
import 'package:apart_mate/presentation/dashboard/controllers/dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Group of properties under one society (or Independent).
class PropertyGroup {
  final String key; // societyId or 'independent'
  final String title;
  final List<PropertyModel> properties;

  const PropertyGroup({
    required this.key,
    required this.title,
    required this.properties,
  });
}

class AddManagerController extends GetxController {
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();

  final isLoading = false.obs;
  final selectedPropertyIds = <String>{}.obs;

  late final DashboardController _dashboard;
  late final LocalManagerRepository _managerRepo;

  /// Every property for this user (all societies + independent).
  List<PropertyModel> get allProperties => _dashboard.properties.toList();

  List<SocietyModel> get societies => _dashboard.societies.toList();

  /// Grouped: one card per society, plus Independent if any.
  List<PropertyGroup> get propertyGroups {
    final props = allProperties;
    final groups = <PropertyGroup>[];

    // Society groups
    for (final s in societies) {
      final inSoc = props.where((p) => p.societyId == s.id).toList();
      if (inSoc.isEmpty) continue;
      groups.add(PropertyGroup(
        key: s.id,
        title: s.name,
        properties: inSoc,
      ));
    }

    // Independent (empty societyId)
    final independent =
        props.where((p) => p.societyId.isEmpty).toList();
    if (independent.isNotEmpty) {
      groups.add(PropertyGroup(
        key: 'independent',
        title: 'Independent',
        properties: independent,
      ));
    }

    // Orphan society ids not in societies list (safety)
    final knownIds = societies.map((s) => s.id).toSet();
    final orphans = props
        .where((p) => p.societyId.isNotEmpty && !knownIds.contains(p.societyId))
        .toList();
    if (orphans.isNotEmpty) {
      groups.add(PropertyGroup(
        key: 'other',
        title: 'Other properties',
        properties: orphans,
      ));
    }

    return groups;
  }

  bool isSelected(String id) => selectedPropertyIds.contains(id);

  bool get allSelected {
    final all = allProperties;
    if (all.isEmpty) return false;
    return all.every((p) => selectedPropertyIds.contains(p.id));
  }

  void toggleProperty(String id) {
    if (selectedPropertyIds.contains(id)) {
      selectedPropertyIds.remove(id);
    } else {
      selectedPropertyIds.add(id);
    }
    selectedPropertyIds.refresh();
  }

  void toggleSelectAll() {
    if (allSelected) {
      selectedPropertyIds.clear();
    } else {
      selectedPropertyIds
        ..clear()
        ..addAll(allProperties.map((p) => p.id));
    }
    selectedPropertyIds.refresh();
  }

  void selectGroup(PropertyGroup group) {
    final ids = group.properties.map((p) => p.id);
    final allInGroupSelected =
        group.properties.every((p) => selectedPropertyIds.contains(p.id));
    if (allInGroupSelected) {
      selectedPropertyIds.removeAll(ids);
    } else {
      selectedPropertyIds.addAll(ids);
    }
    selectedPropertyIds.refresh();
  }

  bool isGroupFullySelected(PropertyGroup group) {
    if (group.properties.isEmpty) return false;
    return group.properties.every((p) => selectedPropertyIds.contains(p.id));
  }

  Future<void> saveManager() async {
    final name = fullNameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final cnic = cnicCtrl.text.trim();
    final ids = selectedPropertyIds.toList();

    if (name.isEmpty || phone.isEmpty || cnic.isEmpty) {
      AppSnackbar.info('Missing fields', AppStrings.missingFields);
      return;
    }
    if (ids.isEmpty) {
      AppSnackbar.info(
        'Select property',
        'Please select at least one property',
      );
      return;
    }

    final selected =
        allProperties.where((p) => ids.contains(p.id)).toList();
    final label = selected
        .map((p) {
          final place = p.societyId.isEmpty
              ? 'Independent'
              : (p.building.isEmpty ? p.flatNumber : p.building);
          return 'Flat ${p.flatNumber} · $place';
        })
        .join(', ');

    isLoading.value = true;
    try {
      final manager = await _managerRepo.createManager(
        fullName: name,
        phone: phone,
        cnic: cnic,
        propertyIds: ids,
        propertyLabel: label,
      );
      await _showInviteCodeSheet(manager);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showInviteCodeSheet(ManagerModel manager) async {
    await Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.managerAdded,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.shareCodeWith(manager.fullName),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.successGreenDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                manager.inviteCode,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(
                  letterSpacing: 6,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.managerWillUseCode,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            AppPrimaryButton(
              label: AppStrings.done,
              onPressed: () {
                Get.back(); // close sheet
                // Open Members on Managers tab
                Get.offNamed(
                  AppRoutes.members,
                  arguments: {'tab': 1}, // 1 = Managers
                );
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _dashboard = Get.find<DashboardController>();
    final repo = Get.find<IManagerRepository>();
    _managerRepo = repo is LocalManagerRepository
        ? repo
        : LocalManagerRepository();
  }

  @override
  void onClose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    cnicCtrl.dispose();
    super.onClose();
  }
}