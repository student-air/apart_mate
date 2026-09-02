// lib/presentation/employee_dashboard/views/employee_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/widgets/app_tenant_bottom_nav.dart';
import 'package:apart_mate/presentation/employee_dashboard/controllers/employee_dashboard_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppTenantBottomNav(
        activeTab: TenantNavTab.home,
        onHome: () => AppNavigation.goHome(),
        onUpdates: () => Get.toNamed(AppRoutes.updates),
        onComplaints: () => Get.toNamed(AppRoutes.complaint),
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryDark),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(controller: controller),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoCard(
                        title: 'Role',
                        value: 'Society staff',
                        subtitle: 'Approved by society admin',
                        icon: Icons.badge_rounded,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Society',
                        value: controller.society.value?.name ?? '—',
                        subtitle:
                            controller.society.value?.address ?? '',
                        icon: Icons.apartment_rounded,
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
                              icon: Icons.report_problem_rounded,
                              label: 'Complaints',
                              onTap: controller.openComplaints,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        onTap: controller.openProfile,
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
  final EmployeeDashboardController controller;
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
              'Employee',
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
      padding: const pseudo EdgeInsets.all(16),
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
          width: double.infinity,
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