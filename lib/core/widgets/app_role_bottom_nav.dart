// lib/core/widgets/app_role_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/utils/app_navigation.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_tenant_bottom_nav.dart';
import 'package:apart_mate/routes/app_routes.dart';

enum AppShellTab { home, updates, membersOrComplaints, profile }

class AppRoleBottomNav extends StatelessWidget {
  final AppShellTab activeTab;

  const AppRoleBottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    // Tenant OR employee staff → same navbar as employee home
    if (AppNavigation.isTenant || AppNavigation.isEmployee) {
      return AppTenantBottomNav(
        activeTab: switch (activeTab) {
          AppShellTab.home => TenantNavTab.home,
          AppShellTab.updates => TenantNavTab.updates,
          AppShellTab.membersOrComplaints => TenantNavTab.complaints,
          AppShellTab.profile => TenantNavTab.profile,
        },
        onHome: () => AppNavigation.goHome(),
        onUpdates: () => Get.toNamed(AppRoutes.updates),
        onComplaints: () => Get.toNamed(AppRoutes.complaint),
        onProfile: () => Get.toNamed(AppRoutes.profile),
      );
    }

    // Owner (and acting manager on owner shell)
    return AppBottomNav(
      items: [
        NavItemData(
          icon: Icons.home_rounded,
          label: 'Home',
          isActive: activeTab == AppShellTab.home,
          onTap: () => AppNavigation.goHome(),
        ),
        NavItemData(
          icon: Icons.campaign_rounded,
          label: 'Updates',
          isActive: activeTab == AppShellTab.updates,
          onTap: () => Get.toNamed(AppRoutes.updates),
        ),
        NavItemData(
          icon: Icons.groups_rounded,
          label: 'Members',
          isActive: activeTab == AppShellTab.membersOrComplaints,
          onTap: () => Get.toNamed(AppRoutes.members),
        ),
        NavItemData(
          icon: Icons.person_rounded,
          label: 'Profile',
          isActive: activeTab == AppShellTab.profile,
          onTap: () => Get.toNamed(AppRoutes.profile),
        ),
      ],
    );
  }
}