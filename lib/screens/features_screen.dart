import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';

class FeaturesScreen extends StatefulWidget {
  const FeaturesScreen({super.key});

  @override
  State<FeaturesScreen> createState() => _FeaturesScreenState();
}

class _FeaturesScreenState extends State<FeaturesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.neonGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('TV', style: TextStyle(color: AppColors.background, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('TenantVerify'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PrimaryButton(
              label: 'Get Started',
              onPressed: () => context.go('/auth'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const ParticleBackground(particleCount: 25, particleColor: AppColors.neonGreen),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ContentContainer(
                maxWidth: 1200,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Hero
                    _buildHeroSection(textTheme),
                    const SizedBox(height: 80),
                    // Core Features
                    _buildCoreFeatures(textTheme, isWide),
                    const SizedBox(height: 80),
                    // Security Features
                    _buildSecuritySection(textTheme, isWide),
                    const SizedBox(height: 80),
                    // Integration Features
                    _buildIntegrationSection(textTheme, isWide),
                    const SizedBox(height: 80),
                    // CTA
                    _buildCtaSection(textTheme),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neonGreenGlow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
          ),
          child: Text(
            'PLATFORM FEATURES',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
          child: Text(
            'Everything You Need for\nTrust Verification',
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'A comprehensive suite of tools designed to make tenant verification\nsecure, fast, and completely tamper-proof.',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCoreFeatures(TextTheme textTheme, bool isWide) {
    final features = [
      _FeatureData(
        icon: Icons.fingerprint_rounded,
        title: 'Document Hashing',
        description: 'SHA-256 cryptographic hashing ensures document integrity. Any modification to the original document will result in a completely different hash.',
        color: AppColors.cyberPurple,
        benefits: ['Tamper detection', 'Instant validation', 'Zero-knowledge proof'],
      ),
      _FeatureData(
        icon: Icons.account_tree_rounded,
        title: 'Merkle Tree Proofs',
        description: 'Multiple document hashes are combined into a single Merkle root, enabling efficient verification of any individual document.',
        color: AppColors.warning,
        benefits: ['Efficient storage', 'Batch verification', 'Scalable architecture'],
      ),
      _FeatureData(
        icon: Icons.link_rounded,
        title: 'Blockchain Anchoring',
        description: 'Proofs are permanently recorded on the Polygon blockchain, creating an immutable audit trail that cannot be altered or deleted.',
        color: AppColors.electricBlue,
        benefits: ['Permanent records', 'Decentralized trust', 'Global accessibility'],
      ),
      _FeatureData(
        icon: Icons.qr_code_rounded,
        title: 'QR Verification',
        description: 'Generate scannable QR codes that link directly to blockchain proofs. Any landlord can verify a tenant\'s credentials instantly.',
        color: AppColors.neonGreen,
        benefits: ['Instant verification', 'Mobile-friendly', 'No app required'],
      ),
      _FeatureData(
        icon: Icons.verified_user_rounded,
        title: 'Government API Integration',
        description: 'Direct integration with Aadhaar and PAN verification APIs ensures documents are validated against official records.',
        color: AppColors.error,
        benefits: ['Official validation', 'Real-time checks', 'Compliance ready'],
      ),
      _FeatureData(
        icon: Icons.workspace_premium_rounded,
        title: 'Trust Certificates',
        description: 'Generate professional PDF certificates with embedded QR codes that serve as portable proof of verification.',
        color: AppColors.neonGreen,
        benefits: ['Shareable proof', 'Professional format', 'Reusable across landlords'],
      ),
    ];

    return Column(
      children: [
        Text('CORE CAPABILITIES', style: textTheme.labelSmall?.copyWith(color: AppColors.electricBlue, letterSpacing: 2)),
        const SizedBox(height: 16),
        Text('Built for Security & Scale', style: textTheme.headlineMedium?.semiBold, textAlign: TextAlign.center),
        const SizedBox(height: 48),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 1,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: isWide ? 0.85 : 1.8,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) => _FeatureCard(feature: features[index]),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(TextTheme textTheme, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.cyberPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyberPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.security_rounded, color: AppColors.cyberPurple, size: 28),
              ),
              const SizedBox(width: 16),
              Text('Security First Design', style: textTheme.headlineSmall?.semiBold),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _SecurityBadge(icon: Icons.enhanced_encryption_rounded, label: 'AES-256 Encryption'),
              _SecurityBadge(icon: Icons.vpn_lock_rounded, label: 'Zero-Knowledge Architecture'),
              _SecurityBadge(icon: Icons.privacy_tip_rounded, label: 'GDPR Compliant'),
              _SecurityBadge(icon: Icons.cloud_off_rounded, label: 'No Cloud Storage'),
              _SecurityBadge(icon: Icons.delete_sweep_rounded, label: 'Auto Data Purge'),
              _SecurityBadge(icon: Icons.gpp_good_rounded, label: 'ISO 27001 Ready'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationSection(TextTheme textTheme, bool isWide) {
    return Column(
      children: [
        Text('INTEGRATIONS', style: textTheme.labelSmall?.copyWith(color: AppColors.warning, letterSpacing: 2)),
        const SizedBox(height: 16),
        Text('Seamless Connectivity', style: textTheme.headlineMedium?.semiBold, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          'Connect with the tools and services you already use',
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _IntegrationCard(icon: Icons.account_balance_rounded, name: 'Aadhaar API', status: 'Active'),
            _IntegrationCard(icon: Icons.credit_card_rounded, name: 'PAN Verification', status: 'Active'),
            _IntegrationCard(icon: Icons.hexagon_rounded, name: 'Polygon', status: 'Active'),
            _IntegrationCard(icon: Icons.storage_rounded, name: 'IPFS', status: 'Active'),
            _IntegrationCard(icon: Icons.webhook_rounded, name: 'Webhooks', status: 'Available'),
            _IntegrationCard(icon: Icons.api_rounded, name: 'REST API', status: 'Available'),
          ],
        ),
      ],
    );
  }

  Widget _buildCtaSection(TextTheme textTheme) {
    return AnimatedGradientBorder(
      borderRadius: AppRadius.xl,
      borderWidth: 2,
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          children: [
            Text('Ready to Start?', style: textTheme.headlineMedium?.semiBold, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Join thousands of landlords who trust TenantVerify for secure tenant verification.',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                GlowingButton(label: 'Start Free Trial', icon: Icons.rocket_launch_rounded, onPressed: () => context.go('/auth')),
                SecondaryButton(label: 'View Documentation', icon: Icons.menu_book_rounded, onPressed: () => context.go('/docs')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> benefits;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.benefits,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData feature;
  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final f = widget.feature;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: _isHovered ? f.color.withValues(alpha: 0.5) : AppColors.cardBorder),
          boxShadow: _isHovered ? [BoxShadow(color: f.color.withValues(alpha: 0.2), blurRadius: 20)] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: f.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(f.icon, color: f.color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(f.title, style: textTheme.titleMedium?.semiBold),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                f.description,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: f.benefits.map((b) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: f.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(b, style: textTheme.labelSmall?.copyWith(color: f.color)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SecurityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.cyberPurple),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String status;
  const _IntegrationCard({required this.icon, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(name, style: Theme.of(context).textTheme.labelMedium?.semiBold),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? AppColors.neonGreen.withValues(alpha: 0.15) : AppColors.electricBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? AppColors.neonGreen : AppColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
