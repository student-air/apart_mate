import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_drawer.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:apart_mate/presentation/tenant_dashboard/controllers/tenant_dashboard_controller.dart';

class TenantDashboardView extends GetView<TenantDashboardController> {
  const TenantDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        userName: controller.userName,
        roleLabel: controller.roleLabel,
        societyName: controller.societyName,
        isTenant: true, // always tenant on this screen
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AppAddFab(onPressed: () {}),
      bottomNavigationBar: AppBottomNav(
        items: [
          NavItemData(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: true,
            onTap: AppNavigation.goHome,
          ),
          NavItemData(
            icon: Icons.campaign_rounded,
            label: 'Updates',
            isActive: false,
            onTap: () => Get.toNamed(AppRoutes.updates),
          ),
          NavItemData(
            icon: Icons.report_problem_rounded,
            label: 'Complaints',
            isActive: false,
            onTap: () {
              // Get.toNamed(AppRoutes.complaints); // later
            },
          ),
          NavItemData(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: false,
            onTap: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple header with menu button to open drawer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => IconButton(
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tenant Home',
                    style: AppTextStyles.h3,
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Tenant Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}