// lib/presentation/manage_properties/views/manage_properties_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/data/models/property_model.dart';
import 'package:apart_mate/presentation/manage_properties/controllers/manage_properties_controller.dart';

class ManagePropertiesView extends GetView<ManagePropertiesController> {
  const ManagePropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Properties', style: AppTextStyles.h4),
            Obx(
              () => Text(
                controller.societyName.isEmpty
                    ? 'Active society'
                    : controller.societyName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = controller.properties;

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_work_outlined,
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No properties in this society yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap Add Property below to add your first one',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.accentGreenDark,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final property = list[index];
              final isSelected =
                  controller.selectedProperty?.id == property.id;

              return _PropertyManageCard(
                property: property,
                isSelected: isSelected,
                onTap: () => controller.selectProperty(property),
                onEdit: () => controller.editProperty(property),
              );
            },
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: controller.addProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: AppColors.accentGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_home_rounded, size: 20),
              label: Text(
                'Add Property',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Property card
// ─────────────────────────────────────────────────────────────────────────────

class _PropertyManageCard extends StatelessWidget {
  final PropertyModel property;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _PropertyManageCard({
    required this.property,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radius2xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius2xl),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius2xl),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentGreen.withValues(alpha: 0.5)
                  : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.pastelGreenBg,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.home_rounded,
                      size: 24,
                      color: AppColors.pastelGreenIcon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flat ${property.flatNumber}',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${property.building} · ${property.floor}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelGreenBg,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                        border: Border.all(
                          color:
                              AppColors.accentGreen.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: AppColors.accentGreenDark,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accentGreenDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(
                    label: property.propertyType,
                    bg: AppColors.pastelBlueBg,
                    fg: AppColors.pastelBlueIcon,
                  ),
                  _Chip(
                    label: property.flatType.isEmpty ? '—' : property.flatType,
                    bg: AppColors.surfaceMuted,
                    fg: AppColors.textSecondary,
                  ),
                  _Chip(
                    label: property.isOccupied ? 'Occupied' : 'Vacant',
                    bg: property.isOccupied
                        ? AppColors.pastelOrangeBg
                        : AppColors.pastelGreenBg,
                    fg: property.isOccupied
                        ? AppColors.pastelOrangeIcon
                        : AppColors.accentGreenDark,
                  ),
                  if (isSelected)
                    const _Chip(
                      label: 'Active',
                      bg: AppColors.pastelGreenBg,
                      fg: AppColors.accentGreenDark,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}