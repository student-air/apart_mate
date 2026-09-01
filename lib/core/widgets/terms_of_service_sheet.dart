import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/constants/app_colors.dart';
import 'package:apart_mate/core/constants/app_text_styles.dart';

void showTermsOfServiceSheet() {
  Get.bottomSheet(
    const TermsOfServiceSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class TermsOfServiceSheet extends StatelessWidget {
  const TermsOfServiceSheet({super.key});

  static const _sections = [
  (
    '1. Acceptance of Terms',
    'By creating an account, signing in, or using Apart Mate, you agree to these Terms of Service. '
    'If you do not agree, do not use the app. These terms apply to property owners, tenants, managers, '
    'and any other authorized users of the resident (regular) application.',
  ),
  (
    '2. About Apart Mate',
    'Apart Mate is a property and society management application that helps owners and tenants '
    'manage flats, join societies, invite tenants, track complaints, view updates, and handle related '
    'property workflows. Society-level administration is handled through the separate ApartMate Pro app. '
    'Features may evolve over time as new capabilities are added.',
  ),
  (
    '3. Eligibility and Accounts',
    'You must provide accurate registration information and keep your login credentials secure. '
    'You are responsible for all activity under your account. Do not share your password or invite codes '
    'with unauthorized persons. Notify support or your society administrator promptly if you suspect '
    'unauthorized use of your account.',
  ),
  (
    '4. Roles: Owner and Tenant',
    'Owners may claim units within an approved society, manage property details, invite tenants and managers, '
    'view members, submit or receive complaints, and access owner dashboards. '
    'Tenants join a property using an invite code provided by an owner, confirm property details, and use '
    'tenant-specific features such as complaints and updates. '
    'You must only use features allowed for your role and must not attempt to access another user’s data.',
  ),
  (
    '5. Society Join and Approval',
    'Joining a society requires a valid society join code issued by the society administrator. '
    'Submitting a join request does not guarantee approval. Access to the owner dashboard and related features '
    'may remain limited until the society admin approves your request. False or misleading information may result '
    'in rejection or later suspension of access.',
  ),
  (
    '6. Tenant Invites and Codes',
    'Owners may generate invite codes for tenants. Codes are intended only for the invited person and property. '
    'Misuse of invite codes, sharing codes publicly, or attempting to join a property without authorization is prohibited. '
    'Once a tenant joins, their membership may appear in the owner’s members list and may be visible to the society '
    'admin as a resident record, according to how the platform is configured.',
  ),
  (
    '7. Property and Personal Data',
    'Information collected through Apart Mate — including names, phone numbers, emails, CNIC (where provided), '
    'flat and building details, occupancy status, and related records — is used for legitimate property and society '
    'management purposes. You agree that accurate data is required for the service to work correctly. '
    'Do not upload content you are not allowed to share.',
  ),
  (
    '8. Complaints, Updates, and Communications',
    'Complaints and messages must be accurate and made in good faith. You must not post false, defamatory, '
    'harassing, discriminatory, or unlawful content. Society updates and announcements are provided for information; '
    'urgent safety matters should also be reported through appropriate local authorities when needed.',
  ),
  (
    '9. Acceptable Use',
    'You agree not to:\n'
    '• Use Apart Mate for any illegal purpose\n'
    '• Harass, threaten, or discriminate against other users\n'
    '• Attempt to hack, scrape, reverse-engineer, or disrupt the service\n'
    '• Impersonate another person or misrepresent your role\n'
    '• Upload malware, spam, or harmful content\n'
    '• Interfere with society admin or other users’ lawful use of the platform',
  ),
  (
    '10. Service Availability',
    'Apart Mate is provided on an “as is” and “as available” basis. We aim for reliable service but do not guarantee '
    'uninterrupted, error-free, or always-available access. Features may change, and temporary outages or maintenance '
    'may occur without prior notice.',
  ),
  (
    '11. Intellectual Property',
    'Apart Mate, including its name, logo, design, code, and content, is protected by applicable intellectual property laws. '
    'You may not copy, modify, distribute, or create derivative works from the app except as expressly allowed.',
  ),
  (
    '12. Limitation of Liability',
    'To the fullest extent permitted by law, Apart Mate and its operators are not liable for indirect, incidental, special, '
    'or consequential damages arising from use of the app, including decisions based on data stored in the platform '
    '(such as occupancy, complaints, or contact details). You use the service at your own risk.',
  ),
  (
    '13. Termination',
    'We or your society administrator may suspend or limit access if you violate these terms, misuse the platform, '
    'or if required by law. You may stop using Apart Mate at any time by logging out and discontinuing use. '
    'Upon termination, your right to access the service ends, subject to any data retention rules that apply.',
  ),
  (
    '14. Changes to These Terms',
    'We may update these Terms of Service from time to time. Continued use of Apart Mate after changes take effect '
    'constitutes acceptance of the revised terms. Material changes may be communicated through the app when practical.',
  ),
  (
    '15. Contact',
    'For questions about these Terms of Service, use Help & Support in your Profile, email support@apartmate.app, '
    'or contact your society administrator.',
  ),
];
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
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
              Text('Terms of Service', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                'Last updated: August 2026',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final (title, body) = _sections[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.labelLarge),
                        const SizedBox(height: 6),
                        Text(
                          body,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}