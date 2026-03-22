import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/theme.dart';
import 'package:project/components/responsive_layout.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _verificationComplete = true;
  bool _certificateExpiring = true;
  bool _newTenantAdded = false;
  bool _securityAlerts = true;
  bool _weeklyDigest = true;
  bool _marketingEmails = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('Notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ContentContainer(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.electricBlue.withValues(alpha: 0.1),
                      AppColors.cyberPurple.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.electricBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay Updated',
                            style: textTheme.titleMedium?.semiBold,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customize how you receive notifications',
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Notification channels
              Text(
                'NOTIFICATION CHANNELS',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              _NotificationToggle(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive instant alerts on your device',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              _NotificationToggle(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Get updates sent to your email',
                value: _emailNotifications,
                onChanged: (v) => setState(() => _emailNotifications = v),
              ),
              _NotificationToggle(
                icon: Icons.sms_outlined,
                title: 'SMS Notifications',
                subtitle: 'Receive text message alerts',
                value: _smsNotifications,
                onChanged: (v) => setState(() => _smsNotifications = v),
              ),

              const SizedBox(height: 32),

              // Activity notifications
              Text(
                'ACTIVITY ALERTS',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              _NotificationToggle(
                icon: Icons.verified_rounded,
                title: 'Verification Complete',
                subtitle: 'When a tenant verification is finished',
                value: _verificationComplete,
                onChanged: (v) => setState(() => _verificationComplete = v),
                accentColor: AppColors.neonGreen,
              ),
              _NotificationToggle(
                icon: Icons.schedule_rounded,
                title: 'Certificate Expiring',
                subtitle: 'Alerts before certificates expire',
                value: _certificateExpiring,
                onChanged: (v) => setState(() => _certificateExpiring = v),
                accentColor: AppColors.warning,
              ),
              _NotificationToggle(
                icon: Icons.person_add_outlined,
                title: 'New Tenant Added',
                subtitle: 'When you start a new verification',
                value: _newTenantAdded,
                onChanged: (v) => setState(() => _newTenantAdded = v),
                accentColor: AppColors.electricBlue,
              ),
              _NotificationToggle(
                icon: Icons.security_rounded,
                title: 'Security Alerts',
                subtitle: 'Important security notifications',
                value: _securityAlerts,
                onChanged: (v) => setState(() => _securityAlerts = v),
                accentColor: AppColors.error,
              ),

              const SizedBox(height: 32),

              // Marketing
              Text(
                'OTHER',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              _NotificationToggle(
                icon: Icons.summarize_outlined,
                title: 'Weekly Digest',
                subtitle: 'Summary of your weekly activity',
                value: _weeklyDigest,
                onChanged: (v) => setState(() => _weeklyDigest = v),
              ),
              _NotificationToggle(
                icon: Icons.campaign_outlined,
                title: 'Marketing & Updates',
                subtitle: 'News about features and promotions',
                value: _marketingEmails,
                onChanged: (v) => setState(() => _marketingEmails = v),
              ),

              const SizedBox(height: 32),

              // Save button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notification preferences saved'),
                        backgroundColor: AppColors.neonGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Preferences'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? accentColor;

  const _NotificationToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = accentColor ?? AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: value && accentColor != null
              ? accentColor!.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (accentColor ?? AppColors.surfaceLight).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall?.semiBold),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.neonGreen,
            activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }
}
