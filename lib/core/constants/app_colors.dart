// What it does: every color used anywhere in the app lives here as a named constant.
//Instead of writing Color(0xFF2C2F33) inside a widget, we write AppColors.primaryDark.
// Why this matters: if the client says "make the green a bit darker" after I've built
// 14 screens, you change one line here instead of hunting through every file.
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

//Branding
  static const Color primaryDark = Color(0xFF121416);
  static const Color primaryDarkGradientEnd = Color(0xFF2A2E32);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentGreenDark = Color(0xFF047857);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color successGreenDark = Color(0xFF16A34A);
  static const Color successGreenBg = Color(0xFFDCFCE7);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xB3FFFFFF);
  static const Color textOnDarkFaint = Color(0x80FFFFFF);

  // Borders / dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Status / semantic
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color pending = Color(0xFFEA580C);
  static const Color pendingBg = Color(0xFFFFF7ED);
  static const Color pendingBorder = Color(0xFFFFEDD5);

  static const Color roleAdminBg = Color(0xFFDBEAFE);
  static const Color roleAdminText = Color(0xFF1D4ED8);
  static const Color roleAdminBorder = Color(0xFFBFDBFE);

  static const Color roleReceptionBg = Color(0xFFFCE7F3);
  static const Color roleReceptionText = Color(0xFFBE185D);
  static const Color roleReceptionBorder = Color(0xFFFBCFE8);

  static const Color roleElectricianBg = Color(0xFFFEF9C3);
  static const Color roleElectricianText = Color(0xFFA16207);
  static const Color roleElectricianBorder = Color(0xFFFEF08A);

  static const Color rolePlumberBg = Color(0xFFDCFCE7);
  static const Color rolePlumberText = Color(0xFF15803D);
  static const Color rolePlumberBorder = Color(0xFFBBF7D0);

  static const Color roleSecurityBg = Color(0xFFFEF3C7);
  static const Color roleSecurityText = Color(0xFF92400E);
  static const Color roleSecurityBorder = Color(0xFFFDE68A);

  // Dashboard — pastel icon tiles (Property Status grid + Quick Actions grid).
  // Each pastel color is reused across multiple icons in the dashboard design
  // (e.g. green covers both "Owner Verified" and "Edit Property"), so these
  // are named by hue, not by feature — pick whichever pastel fits the icon.
  static const Color pastelGreenBg = Color(0xFFD1FAE5);
  static const Color pastelGreenIcon = Color(0xFF10B981);

  static const Color pastelBlueBg = Color(0xFFDBEAFE);
  static const Color pastelBlueIcon = Color(0xFF3B82F6);

  static const Color pastelOrangeBg = Color(0xFFFFEDD5);
  static const Color pastelOrangeIcon = Color(0xFFF97316);

  static const Color pastelPurpleBg = Color(0xFFEDE9FE);
  static const Color pastelPurpleIcon = Color(0xFF8B5CF6);

  static const Color pastelRedBg = Color(0xFFFEE2E2);
  static const Color pastelRedIcon = Color(0xFFEF4444);

  // Dashboard — header building illustration backdrop (the green dome/arc
  // behind the building graphic).
  static const Color headerIllustrationAccent = Color(0xFF6EE7B7);

  static const pastelPinkBg = Color(0xFFFCE7F3);   // soft pink background
static const pastelPinkIcon = Color(0xFFDB2777); // deeper pink for icons
}

extension ColorValues on Color {
  /// Convenience method used across the app to set opacity using a named
  /// parameter (`alpha`) matching existing usages like `color.withValues(alpha: 0.6)`.
  Color withValues({double? alpha}) {
    if (alpha != null) return withOpacity(alpha);
    return this;
  }
}