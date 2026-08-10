// lib/core/widgets/app_bottom_nav.dart — full file

import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';

enum AppNavTab { home, updates, requests, profile, none }

class AppAddFab extends StatelessWidget {
  final VoidCallback onPressed;
  const AppAddFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      elevation: 3,
      onPressed: onPressed,
      child: const Icon(Icons.add, color: AppColors.accentGreen, size: 26),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final AppNavTab activeTab;
  final VoidCallback onHome;
  final VoidCallback onUpdates;
  final VoidCallback onRequests;
  final VoidCallback onProfile;

  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onHome,
    required this.onUpdates,
    required this.onRequests,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      padding: EdgeInsets.zero,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: activeTab == AppNavTab.home,
                  onTap: onHome,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.campaign_rounded,
                  label: 'Updates',
                  isActive: activeTab == AppNavTab.updates,
                  onTap: onUpdates,
                ),
              ),
              const SizedBox(width: 36),
              Expanded(
                child: _NavItem(
                  icon: Icons.assignment_rounded,
                  label: 'Requests',
                  isActive: activeTab == AppNavTab.requests,
                  onTap: onRequests,
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: activeTab == AppNavTab.profile,
                  onTap: onProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.accentGreen : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 9.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}