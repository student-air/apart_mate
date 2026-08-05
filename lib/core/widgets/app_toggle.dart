import 'package:flutter/material.dart';
import 'package:apart_mate/core/constants/app_colors.dart';

class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AppColors.successGreen : AppColors.border,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, 1))],
          ),
        ),
      ),
    );
  }
}