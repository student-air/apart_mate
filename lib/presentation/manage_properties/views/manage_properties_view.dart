// lib/presentation/manage_properties/views/manage_properties_view.dart

import 'package:apart_mate/routes/app_routes.dart';
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
      body: Column(
        children: [
          // ── Header (Updates style) ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppDimens.headerRadius),
                bottomRight: Radius.circular(AppDimens.headerRadius),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed( AppRoutes.dashboard),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textOnDark.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textOnDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'My Properties',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.addProperty,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.textOnDark.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.textOnDark,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: const Icon(
                          Icons.villa_rounded,
                          size: 22,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentGreenDark,
                  ),
                );
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
                          'No properties yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first property',
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
                      onSold: () => controller.markAsSold(property),
                      onDelete: () => controller.deleteProperty(property),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
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
  final VoidCallback onSold;
  final VoidCallback onDelete;

  const _PropertyManageCard({
    required this.property,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onSold,
    required this.onDelete,
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
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppColors.surface,
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'sold') onSold();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Edit property',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'sold',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sell_rounded,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Mark as sold',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          label: property.propertyType.isEmpty
                              ? '—'
                              : property.propertyType,
                          bg: AppColors.pastelBlueBg,
                          fg: AppColors.pastelBlueIcon,
                        ),
                        _Chip(
                          label: property.flatType.isEmpty
                              ? '—'
                              : property.flatType,
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
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: const Icon(
                        Icons.delete_rounded,
                        size: 14,
                        color: AppColors.textOnDark,
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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