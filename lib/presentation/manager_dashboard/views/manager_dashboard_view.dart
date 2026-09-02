// lib/presentation/manager_dashboard/views/manager_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/presentation/manager_dashboard/controllers/manager_dashboard_controller.dart';

class ManagerDashboardView extends GetView<ManagerDashboardController> {
  const ManagerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryDark),
          );
        }

        final m = controller.manager.value;

        return RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(controller: controller)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoCard(
                        title: 'Role',
                        value: 'Property manager',
                        subtitle: 'Invited by property owner',
                        icon: Icons.manage_accounts_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Properties',
                        value: (m?.propertyLabel.isNotEmpty == true)
                            ? m!.propertyLabel
                            : '—',
                        subtitle: m?.fullName ?? '',
                        icon: Icons.home_work_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Status',
                        value: (m?.status ?? '—').toUpperCase(),
                        subtitle: m != null ? 'Invite linked to your account' : '',
                        icon: Icons.verified_rounded,
                      ),
                      const SizedBox(height: 20),
                      Text('Quick actions', style: AppTextStyles.h4),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.campaign_rounded,
                              label: 'Updates',
                              onTap: controller.openUpdates,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionTile(
                              icon: Icons.person_rounded,
                              label: 'Profile',
                              onTap: controller.openProfile,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  final ManagerDashboardController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manager',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hi, ${controller.userName.value}',
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryDark),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}