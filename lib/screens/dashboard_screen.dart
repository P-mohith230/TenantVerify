import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/app_card.dart';
import 'package:project/components/tenant_card.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/verification_provider.dart';
import 'package:project/models/verification.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  VerificationStatus? _statusFilter;
  int _navigationIndex = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VerificationProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentIndex: _navigationIndex,
      onNavigationChanged: (index) {
        setState(() => _navigationIndex = index);
        switch (index) {
          case 0:
            break;
          case 1:
            context.push('/verify');
            break;
          case 2:
            context.push('/settings');
            break;
          case 3:
            context.push('/help');
            break;
        }
      },
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.add_circle_outline, selectedIcon: Icons.add_circle_rounded, label: 'Verify'),
        NavigationItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Settings'),
        NavigationItem(icon: Icons.help_outline_rounded, selectedIcon: Icons.help_rounded, label: 'Help'),
      ],
      floatingActionButton: isMobile(context) ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGreen.withValues(alpha: 0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/verify'),
          backgroundColor: AppColors.neonGreen,
          icon: const Icon(Icons.add_rounded, color: AppColors.background),
          label: const Text(
            'New Verification',
            style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w600),
          ),
        ),
      ) : null,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Consumer<VerificationProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.neonGreen),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => provider.initialize(),
          color: AppColors.neonGreen,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: ContentContainer(
              maxWidth: 1200,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _DashboardHeader(pulseController: _pulseController),
                  const SizedBox(height: 32),
                  
                  // Stats
                  _StatsSection(stats: provider.stats),
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  if (isWide) _QuickActions(),
                  if (isWide) const SizedBox(height: 32),
                  
                  // Tenants section
                  Row(
                    children: [
                      Text('Recent Verifications', style: textTheme.titleLarge?.semiBold),
                      const Spacer(),
                      if (isWide)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonGreen.withValues(alpha: 0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/verify'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonGreen,
                              foregroundColor: AppColors.background,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('New Verification'),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search and filters
                  _SearchAndFilters(
                    searchQuery: _searchQuery,
                    statusFilter: _statusFilter,
                    onSearchChanged: (query) => setState(() => _searchQuery = query),
                    onStatusFilterChanged: (status) => setState(() => _statusFilter = status),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tenant list
                  _TenantList(
                    provider: provider,
                    searchQuery: _searchQuery,
                    statusFilter: _statusFilter,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final AnimationController pulseController;

  const _DashboardHeader({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Container(
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
          // Status indicator
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.3 + 0.2 * pulseController.value),
                      blurRadius: 20,
                      spreadRadius: 2 * pulseController.value,
                    ),
                  ],
                ),
                child: const Icon(Icons.verified_user_rounded, color: AppColors.background, size: 28),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back${user != null ? ", ${user.displayName}" : ""}',
                  style: textTheme.titleLarge?.semiBold,
                ),
                const SizedBox(height: 4),
                if (user?.walletAddress != null)
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
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user!.shortWalletAddress,
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
          PopupMenuButton(
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            color: AppColors.surface,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Text(
                  user?.displayName[0].toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => context.push('/settings'),
                child: const Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  auth.signOut();
                  context.go('/');
                },
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final Map<String, int> stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isWide ? 2.2 : 1.6,
      children: [
        _StatCard(
          icon: Icons.people_outline_rounded,
          label: 'Total Tenants',
          value: '${stats['totalTenants'] ?? 0}',
          color: AppColors.electricBlue,
          index: 0,
        ),
        _StatCard(
          icon: Icons.verified_rounded,
          label: 'Verified',
          value: '${stats['verified'] ?? 0}',
          color: AppColors.neonGreen,
          index: 1,
        ),
        _StatCard(
          icon: Icons.schedule_rounded,
          label: 'Pending',
          value: '${stats['pending'] ?? 0}',
          color: AppColors.warning,
          index: 2,
        ),
        _StatCard(
          icon: Icons.workspace_premium_rounded,
          label: 'Certificates',
          value: '${stats['certificates'] ?? 0}',
          color: AppColors.cyberPurple,
          index: 3,
        ),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int index;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.index = 0,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: _isHovered 
                        ? widget.color.withValues(alpha: 0.5) 
                        : widget.color.withValues(alpha: 0.2),
                  ),
                  boxShadow: _isHovered ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ] : null,
                ),
                transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
                transformAlignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: _isHovered ? 0.25 : 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(widget.icon, size: 20, color: widget.color),
                        ),
                        const Spacer(),
                        Text(
                          widget.value,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.label,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Scan Certificate',
            subtitle: 'Verify a tenant\'s certificate',
            color: AppColors.electricBlue,
            onTap: () => context.push('/qr-verify'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.analytics_rounded,
            title: 'View Analytics',
            subtitle: 'Track verification metrics',
            color: AppColors.cyberPurple,
            onTap: () => context.push('/analytics'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleSmall?.semiBold),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final String searchQuery;
  final VerificationStatus? statusFilter;
  final Function(String) onSearchChanged;
  final Function(VerificationStatus?) onStatusFilterChanged;

  const _SearchAndFilters({
    required this.searchQuery,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: isWide ? 300 : double.infinity,
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search tenants...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        ...VerificationStatus.values.where((s) => s != VerificationStatus.processing).map((status) {
          final isSelected = statusFilter == status;
          final color = _getStatusColor(status);
          
          return FilterChip(
            label: Text(_getStatusLabel(status)),
            selected: isSelected,
            onSelected: (selected) => onStatusFilterChanged(selected ? status : null),
            showCheckmark: false,
            backgroundColor: AppColors.surface,
            selectedColor: color.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: isSelected ? color : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? color : AppColors.cardBorder,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          );
        }),
      ],
    );
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return AppColors.warning;
      case VerificationStatus.processing:
        return AppColors.electricBlue;
      case VerificationStatus.verified:
        return AppColors.neonGreen;
      case VerificationStatus.failed:
        return AppColors.error;
      case VerificationStatus.revoked:
        return AppColors.textMuted;
    }
  }

  String _getStatusLabel(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.processing:
        return 'Processing';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.failed:
        return 'Failed';
      case VerificationStatus.revoked:
        return 'Revoked';
    }
  }
}

class _TenantList extends StatelessWidget {
  final VerificationProvider provider;
  final String searchQuery;
  final VerificationStatus? statusFilter;

  const _TenantList({
    required this.provider,
    required this.searchQuery,
    required this.statusFilter,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    var tenants = provider.tenants;
    
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      tenants = tenants.where((t) => 
        t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        t.email.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by status
    if (statusFilter != null) {
      tenants = tenants.where((t) {
        final verification = provider.getVerificationForTenant(t.id);
        return verification?.status == statusFilter;
      }).toList();
    }

    if (tenants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              searchQuery.isNotEmpty || statusFilter != null
                  ? 'No tenants match your filters'
                  : 'No verifications yet',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by verifying your first tenant',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/verify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.background,
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Start Verification'),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tenants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tenant = tenants[index];
        final verification = provider.getVerificationForTenant(tenant.id);
        final certificate = provider.getCertificateForTenant(tenant.id);

        return TenantCard(
          tenant: tenant,
          status: verification?.status,
          hasCertificate: certificate != null && !certificate.isRevoked,
          verificationDate: verification?.completedAt ?? verification?.startedAt,
          onTap: () {
            if (certificate != null) {
              context.push('/certificate/${certificate.id}');
            } else if (verification != null && verification.status == VerificationStatus.pending) {
              context.push('/progress/${verification.id}');
            }
          },
        );
      },
    );
  }
}
