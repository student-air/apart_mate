import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_dimens.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';
import 'package:apart_mate/core/widgets/app_bottom_nav.dart';
import 'package:apart_mate/core/widgets/app_responsive_container.dart';
//import 'package:apart_mate/core/widgets/send_update_sheet.dart';
import 'package:apart_mate/data/models/update_model.dart';
import 'package:apart_mate/presentation/updates/controllers/updates_controller.dart';
import 'package:apart_mate/routes/app_routes.dart';
import 'package:apart_mate/core/widgets/app_skeletons.dart';

class UpdatesView extends GetView<UpdatesController> {
  const UpdatesView({super.key});

  Future<void> _confirmClearAll(BuildContext context) async {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Clear all updates?',
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This will permanently remove every update from this list.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.clearAll();
                },
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                label: Text(
                  'Clear All',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: -10,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 32, fit: BoxFit.cover),
            const SizedBox(width: 2),
            Text('Updates', style: AppTextStyles.h3.copyWith(color: Colors.white)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(() {
            if (controller.updates.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () => _confirmClearAll(context),
              child: const Text('Clear All', style: TextStyle(color: AppColors.accentGreen)),
            );
          }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: AppAddFab(
      //   // onPressed: showSendUpdateSheet,
      // ),
      bottomNavigationBar: AppBottomNav(
        activeTab: AppNavTab.updates,
        onHome: () => Get.offNamed(AppRoutes.dashboard),
        onUpdates: () {}, // already here
        onRequests: () {}, //=> Get.offNamed(AppRoutes.requests),
        onProfile: () => Get.toNamed(AppRoutes.profile),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.updates.isEmpty) {
            return const AppSkeletonList(itemBuilder: UpdateCardSkeleton.new);
          }
          if (controller.updates.isEmpty) {
            return _EmptyState(onRefresh: controller.refresh);
          }
          return RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: controller.refresh,
            child: AppResponsiveContainer(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: controller.updates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final update = controller.updates[index];
                  return Dismissible(
                    key: ValueKey(update.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) => controller.deleteUpdate(update.id),
                    child: _UpdateCard(update: update),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final UpdateModel update;
  const _UpdateCard({required this.update});

  ({Color bg, Color text, Color border, String label}) get _typeStyle {
    switch (update.type) {
      case UpdateType.security:
        return (bg: AppColors.dangerBg, text: AppColors.danger, border: AppColors.dangerBorder, label: 'Security Alert');
      case UpdateType.announcement:
        return (bg: AppColors.roleAdminBg, text: AppColors.roleAdminText, border: AppColors.roleAdminBorder, label: 'Announcement');
      case UpdateType.general:
        return (bg: AppColors.warningBg, text: AppColors.warning, border: AppColors.warningBorder, label: 'General Update');
      case UpdateType.other:
        return (bg: const Color.fromARGB(255, 172, 232, 194), text: AppColors.accentGreenDark, border: AppColors.accentGreenDark, label: 'Other');
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _typeStyle;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  border: Border.all(color: style.border),
                ),
                child: Text(
                  style.label,
                  style: AppTextStyles.labelSmall.copyWith(color: style.text),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(update.postedAt),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            update.category ?? 'Update',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 4),
          Text(
            update.description,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            update.destinationLabel,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return DateFormat('h:mm a').format(date);
    return DateFormat('MMM d').format(date);
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie/updates.json',
                    width: 320,
                    height: 280,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                  const SizedBox(height: 20),
                  Text('No updates yet', style: AppTextStyles.h4),
                  const SizedBox(height: 6),
                  Text(
                    'Updates and announcements\nwill show up here.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}