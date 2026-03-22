import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/theme.dart';
import 'package:project/components/app_card.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ContentContainer(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonGreen.withValues(alpha: 0.1),
                      AppColors.electricBlue.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.neonGradient,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen.withValues(alpha: 0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          auth.user?.displayName[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.user?.displayName ?? 'User',
                            style: textTheme.titleMedium?.semiBold,
                          ),
                          const SizedBox(height: 4),
                          if (auth.user?.walletAddress != null)
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.neonGreen,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neonGreen.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  auth.user!.shortWalletAddress,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Account settings
              Text(
                'ACCOUNT',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Profile',
                subtitle: 'Manage your account details',
                onTap: () => context.push('/profile'),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Configure alerts and updates',
                onTap: () => context.push('/notifications'),
              ),
              _SettingsTile(
                icon: Icons.security_rounded,
                title: 'Security',
                subtitle: 'Password and authentication',
                onTap: () => context.push('/security'),
              ),
              
              const SizedBox(height: 32),
              
              // Blockchain settings
              Text(
                'BLOCKCHAIN',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet',
                subtitle: 'Manage connected wallets',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    'Connected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonGreen,
                    ),
                  ),
                ),
                onTap: () => context.push('/security'),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Network',
                subtitle: 'Polygon Mumbai (Testnet)',
                onTap: () => _showNetworkDialog(context),
              ),
              
              const SizedBox(height: 32),
              
              // App settings
              Text(
                'APP',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'FAQs and contact us',
                onTap: () => context.push('/help'),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Privacy',
                subtitle: 'Legal documents',
                onTap: () => context.push('/help'),
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              
              const SizedBox(height: 32),
              
              // Sign out
              Container(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    auth.signOut();
                    context.go('/');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNetworkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Select Network'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NetworkOption(
              name: 'Polygon Mumbai',
              type: 'Testnet',
              isSelected: true,
            ),
            const SizedBox(height: 12),
            _NetworkOption(
              name: 'Polygon Mainnet',
              type: 'Production',
              isSelected: false,
              isDisabled: true,
            ),
            const SizedBox(height: 12),
            _NetworkOption(
              name: 'Ethereum Mainnet',
              type: 'Production',
              isSelected: false,
              isDisabled: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'TV',
                  style: TextStyle(
                    color: AppColors.background,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TenantVerify',
              style: Theme.of(context).textTheme.titleLarge?.semiBold,
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'A blockchain-powered tenant verification platform built for the Dreamflow Buildathon 2025.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AboutBadge(icon: Icons.link_rounded, label: 'Polygon'),
                const SizedBox(width: 8),
                _AboutBadge(icon: Icons.flutter_dash, label: 'Flutter'),
                const SizedBox(width: 8),
                _AboutBadge(icon: Icons.cloud_outlined, label: 'Dreamflow'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _NetworkOption extends StatelessWidget {
  final String name;
  final String type;
  final bool isSelected;
  final bool isDisabled;

  const _NetworkOption({
    required this.name,
    required this.type,
    required this.isSelected,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.neonGreen.withValues(alpha: 0.1)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected
              ? AppColors.neonGreen.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.neonGreen : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isDisabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Text(
                'SOON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AboutBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AboutBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: AppColors.textSecondary, size: 22),
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
                trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
