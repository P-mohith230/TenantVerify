import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project/theme.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/providers/auth_provider.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;
  bool _sessionAlerts = true;

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
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('Security'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ContentContainer(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security score
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonGreen.withValues(alpha: 0.15),
                      AppColors.electricBlue.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: 0.85,
                            strokeWidth: 8,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation(AppColors.neonGreen),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '85',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neonGreen,
                              ),
                            ),
                            Text(
                              '/100',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Score',
                            style: textTheme.titleMedium?.semiBold,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your account is well protected. Enable 2FA to improve your score.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Authentication methods
              Text(
                'AUTHENTICATION',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              _SecurityTile(
                icon: Icons.password_rounded,
                title: 'Change Password',
                subtitle: 'Last changed 30 days ago',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _SecurityToggleTile(
                icon: Icons.security_rounded,
                title: 'Two-Factor Authentication',
                subtitle: _twoFactorEnabled ? 'Enabled via authenticator app' : 'Add an extra layer of security',
                value: _twoFactorEnabled,
                onChanged: (v) => _enableTwoFactor(v),
                recommended: !_twoFactorEnabled,
              ),
              _SecurityToggleTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face to sign in',
                value: _biometricEnabled,
                onChanged: (v) => setState(() => _biometricEnabled = v),
              ),

              const SizedBox(height: 32),

              // Wallet security
              Text(
                'WALLET SECURITY',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cyberPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.cyberPurple,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Connected Wallet', style: textTheme.titleSmall?.semiBold),
                              const SizedBox(height: 2),
                              Text(
                                auth.user?.shortWalletAddress ?? 'No wallet connected',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text(
                            'SECURED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.cardBorder),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _WalletAction(
                          icon: Icons.refresh_rounded,
                          label: 'Reconnect',
                          onTap: () {},
                        ),
                        _WalletAction(
                          icon: Icons.link_off_rounded,
                          label: 'Disconnect',
                          onTap: () => _showDisconnectWalletDialog(context),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Session management
              Text(
                'SESSIONS',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              _SecurityToggleTile(
                icon: Icons.devices_rounded,
                title: 'Session Alerts',
                subtitle: 'Get notified of new login activity',
                value: _sessionAlerts,
                onChanged: (v) => setState(() => _sessionAlerts = v),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Sessions', style: textTheme.titleSmall?.semiBold),
                    const SizedBox(height: 16),
                    _SessionItem(
                      device: 'Chrome on Windows',
                      location: 'Mumbai, India',
                      lastActive: 'Active now',
                      isCurrent: true,
                    ),
                    const SizedBox(height: 12),
                    _SessionItem(
                      device: 'Safari on iPhone',
                      location: 'Mumbai, India',
                      lastActive: '2 hours ago',
                      isCurrent: false,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => _showLogoutAllDialog(context),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sign out all other sessions'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Danger zone
              Text(
                'DANGER ZONE',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Delete Account',
                          style: textTheme.titleSmall?.copyWith(color: AppColors.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Once you delete your account, there is no going back. All your data will be permanently removed.',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _showDeleteAccountDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                      ),
                      child: const Text('Delete my account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password updated successfully'),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _enableTwoFactor(bool enable) {
    if (enable) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Enable Two-Factor Authentication'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      color: Colors.white,
                      child: const Center(
                        child: Icon(Icons.qr_code_2_rounded, size: 100, color: AppColors.background),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Scan with your authenticator app',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter verification code',
                  prefixIcon: Icon(Icons.pin_rounded),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _twoFactorEnabled = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Two-factor authentication enabled'),
                    backgroundColor: AppColors.neonGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.background,
              ),
              child: const Text('Enable'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _twoFactorEnabled = false);
    }
  }

  void _showDisconnectWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Disconnect Wallet?'),
        content: const Text('You will need to reconnect your wallet to sign transactions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wallet disconnected')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _showLogoutAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out All Sessions?'),
        content: const Text('This will sign you out from all devices except this one.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out from all other sessions')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. All your verifications, certificates, and data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SecurityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool recommended;

  const _SecurityToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                Row(
                  children: [
                    Text(title, style: textTheme.titleSmall?.semiBold),
                    if (recommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textSecondary;

    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final String device;
  final String location;
  final String lastActive;
  final bool isCurrent;

  const _SessionItem({
    required this.device,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.neonGreen.withValues(alpha: 0.05) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isCurrent ? Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(
            device.contains('iPhone') ? Icons.phone_iphone_rounded : Icons.computer_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device, style: textTheme.bodySmall?.semiBold),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'THIS DEVICE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$location • $lastActive',
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
