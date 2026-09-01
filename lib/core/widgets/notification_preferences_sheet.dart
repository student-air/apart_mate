import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/presentation/profile/controllers/profile_controller.dart';

void showNotificationPreferencesSheet() {
  Get.bottomSheet(
    const NotificationPreferencesSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class NotificationPreferencesSheet extends StatelessWidget {
  const NotificationPreferencesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Notification Preferences', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'Choose what you want to be notified about.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Obx(() => _ToggleRow(
                      icon: Icons.campaign_rounded,
                      title: 'Updates & Announcements',
                      subtitle: 'Society notices and posts',
                      value: c.notifyUpdates.value,
                      onChanged: c.setNotifyUpdates,
                    )),
                const Divider(height: 20, color: AppColors.borderLight),
                Obx(() => _ToggleRow(
                      icon: Icons.report_problem_rounded,
                      title: 'Complaints',
                      subtitle: c.isTenant
                          ? 'Status changes on your complaints'
                          : 'New complaints on your properties',
                      value: c.notifyComplaints.value,
                      onChanged: c.setNotifyComplaints,
                    )),
                if (!c.isTenant) ...[
                  const Divider(height: 20, color: AppColors.borderLight),
                  Obx(() => _ToggleRow(
                        icon: Icons.person_add_rounded,
                        title: 'Tenant activity',
                        subtitle: 'When a tenant joins with your invite code',
                        value: c.notifyTenantActivity.value,
                        onChanged: c.setNotifyTenantActivity,
                      )),
                ],
                const Divider(height: 20, color: AppColors.borderLight),
                Obx(() => _ToggleRow(
                      icon: Icons.volume_up_rounded,
                      title: 'Notification sound',
                      subtitle: 'Play a sound for alerts',
                      value: c.notifySound.value,
                      onChanged: c.setNotifySound,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
              ),
              child: Text(
                'Done',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: value
                ? AppColors.accentGreen.withValues(alpha: 0.12)
                : AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 19,
            color: value ? AppColors.successGreenDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.accentGreen,
        ),
      ],
    );
  }
}