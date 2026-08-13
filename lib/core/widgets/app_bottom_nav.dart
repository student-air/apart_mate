// lib/core/widgets/app_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';

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

class NavItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const NavItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isActive,
  });
}

class AppBottomNav extends StatelessWidget {
  final List<NavItemData> items;

  const AppBottomNav({
    super.key,
    required this.items,
  }) : assert(items.length == 4, 'AppBottomNav needs exactly 4 items');

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
              Expanded(child: _NavItem(data: items[0])),
              Expanded(child: _NavItem(data: items[1])),
              const SizedBox(width: 36),
              Expanded(child: _NavItem(data: items[2])),
              Expanded(child: _NavItem(data: items[3])),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavItemData data;
  const _NavItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.isActive ? AppColors.accentGreen : AppColors.textMuted;

    return InkWell(
      onTap: data.onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, size: 20, color: color),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.label,
                maxLines: 1,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight:
                      data.isActive ? FontWeight.w700 : FontWeight.w500,
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