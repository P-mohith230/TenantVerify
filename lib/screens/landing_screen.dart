import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background grid
          const _AnimatedGrid(),
          // Particle background
          const ParticleBackground(
            particleCount: 40,
            particleColor: AppColors.neonGreen,
          ),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _Navbar(),
                    _HeroSection(
                      pulseController: _pulseController,
                      rotateController: _rotateController,
                      floatController: _floatController,
                    ),
                    const _TrustProblemSection(),
                    const _SolutionSection(),
                    const _TechStackSection(),
                    const _PipelineVisualization(),
                    const _StatsSection(),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGrid extends StatelessWidget {
  const _AnimatedGrid();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cardBorder.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 50.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Logo with glow
          _GlowingLogo(),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
            child: Text(
              'TenantVerify',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          if (isWide) ...[
            _NavLink(label: 'Features', onTap: () => context.go('/features')),
            _NavLink(label: 'How It Works', onTap: () => context.go('/how-it-works')),
            _NavLink(label: 'Docs', onTap: () => context.go('/docs')),
            const SizedBox(width: 24),
          ],
          _GlowButton(
            label: isWide ? 'Launch App' : 'Launch',
            onPressed: () => context.go('/auth'),
          ),
        ],
      ),
    );
  }
}

class _GlowingLogo extends StatefulWidget {
  @override
  State<_GlowingLogo> createState() => _GlowingLogoState();
}

class _GlowingLogoState extends State<_GlowingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.neonGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.4 + 0.3 * _controller.value),
                blurRadius: 15 + 10 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'TV',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _GlowButton({required this.label, required this.onPressed});

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.3 + 0.2 * _controller.value),
                  blurRadius: _isHovered ? 30 : 20 + 10 * _controller.value,
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isHovered ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.arrow_forward_rounded, size: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final AnimationController pulseController;
  final AnimationController rotateController;
  final AnimationController floatController;

  const _HeroSection({
    required this.pulseController,
    required this.rotateController,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isWide ? 80 : 48,
      ),
      child: ContentContainer(
        maxWidth: 1000,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Animated blockchain graphic
            AnimatedBuilder(
              animation: Listenable.merge([rotateController, floatController]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, math.sin(floatController.value * math.pi * 2) * 10),
                  child: _BlockchainGraphic(rotation: rotateController.value),
                );
              },
            ),
            const SizedBox(height: 48),
            
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neonGreenGlow,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'BLOCKCHAIN-POWERED TRUST INFRASTRUCTURE',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Main headline
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
                children: [
                  const TextSpan(text: 'Verify tenants with\n'),
                  TextSpan(
                    text: 'cryptographic certainty',
                    style: TextStyle(
                      foreground: Paint()..shader = AppColors.neonGradient.createShader(
                        const Rect.fromLTWH(0, 0, 400, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Subheading
            Text(
              'Transform document verification into immutable blockchain proofs.\nBuild trust that cannot be faked, forged, or forgotten.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // CTAs
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _GlowButton(
                  label: 'Start Verification',
                  onPressed: () => context.go('/auth'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/features'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.explore_rounded, size: 20),
                  label: const Text('Explore Features'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            
            // Terminal-like code snippet
            _TerminalSnippet(),
          ],
        ),
      ),
    );
  }
}

class _BlockchainGraphic extends StatelessWidget {
  final double rotation;

  const _BlockchainGraphic({required this.rotation});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      width: 180,
      child: BlockchainNodes(
        size: 180,
        nodeCount: 6,
        duration: Duration(seconds: 20),
      ),
    );
  }
}

class _TerminalSnippet extends StatefulWidget {
  @override
  State<_TerminalSnippet> createState() => _TerminalSnippetState();
}

class _TerminalSnippetState extends State<_TerminalSnippet> {
  bool _showLine1 = false;
  bool _showLine2 = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showLine1 = true);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showLine2 = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBorder(
      borderRadius: AppRadius.lg,
      borderWidth: 1,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terminal header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  _AnimatedDot(color: AppColors.error, delay: 0),
                  const SizedBox(width: 8),
                  _AnimatedDot(color: AppColors.warning, delay: 100),
                  const SizedBox(width: 8),
                  _AnimatedDot(color: AppColors.neonGreen, delay: 200),
                  const SizedBox(width: 16),
                  Text(
                    'TenantVerify Protocol',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            // Code content with typewriter effect
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showLine1)
                    TypewriterText(
                      text: '> Document → SHA256 → MerkleRoot → Blockchain',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.neonGreen,
                      ),
                      duration: const Duration(milliseconds: 40),
                    ),
                  const SizedBox(height: 4),
                  if (_showLine2)
                    TypewriterText(
                      text: '> Status: IMMUTABLE_PROOF_GENERATED ✓',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.neonGreen,
                      ),
                      duration: const Duration(milliseconds: 40),
                    ),
                  if (!_showLine1)
                    const SizedBox(height: 26),
                  if (!_showLine2 && _showLine1)
                    const SizedBox(height: 26),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final Color color;
  final int delay;

  const _AnimatedDot({required this.color, required this.delay});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _TrustProblemSection extends StatelessWidget {
  const _TrustProblemSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ContentContainer(
        maxWidth: 1100,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Section label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'THE PROBLEM',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Trust is broken.',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Documents can be faked. Identities can be forged.\nTraditional verification is slow, expensive, and unreliable.',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Problem cards
            GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isWide ? 1.3 : 3,
              children: const [
                _ProblemCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Fake Documents',
                  description: '40% of rental frauds involve forged IDs',
                  color: AppColors.error,
                ),
                _ProblemCard(
                  icon: Icons.timer_off_outlined,
                  title: 'Slow Verification',
                  description: 'Manual checks take 3-7 days',
                  color: AppColors.warning,
                ),
                _ProblemCard(
                  icon: Icons.repeat_rounded,
                  title: 'Repeated Checks',
                  description: 'Same tenant verified multiple times',
                  color: AppColors.cyberPurple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _ProblemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: textTheme.titleSmall?.semiBold),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SolutionSection extends StatelessWidget {
  const _SolutionSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, AppColors.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ContentContainer(
        maxWidth: 1100,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'THE SOLUTION',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.neonGreen,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
              child: Text(
                'Cryptographic Certainty',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transform documents into tamper-proof blockchain proofs.\nVerify once, trust everywhere.',
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Solution features
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isWide ? 0.9 : 0.95,
              children: const [
                _SolutionCard(
                  icon: Icons.fingerprint_rounded,
                  title: 'Hash',
                  description: 'SHA-256 document fingerprints',
                ),
                _SolutionCard(
                  icon: Icons.account_tree_rounded,
                  title: 'Merkle',
                  description: 'Combine into single proof',
                ),
                _SolutionCard(
                  icon: Icons.link_rounded,
                  title: 'Anchor',
                  description: 'Record on blockchain',
                ),
                _SolutionCard(
                  icon: Icons.verified_rounded,
                  title: 'Verify',
                  description: 'Instant QR verification',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SolutionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SolutionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_SolutionCard> createState() => _SolutionCardState();
}

class _SolutionCardState extends State<_SolutionCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _isHovered 
                ? AppColors.neonGreen.withValues(alpha: 0.5) 
                : AppColors.neonGreen.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGreen.withValues(alpha: _isHovered ? 0.3 : 0.1),
              blurRadius: _isHovered ? 30 : 20,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.neonGradient,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: _isHovered ? [
                      BoxShadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.3 + 0.2 * _pulseController.value),
                        blurRadius: 15 + 5 * _pulseController.value,
                      ),
                    ] : null,
                  ),
                  child: Icon(widget.icon, color: AppColors.background, size: 28),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(widget.title, style: textTheme.titleMedium?.semiBold),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TechStackSection extends StatelessWidget {
  const _TechStackSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ContentContainer(
        maxWidth: 800,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Text(
              'BUILT WITH',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _TechBadge(label: 'SHA-256'),
                _TechBadge(label: 'Merkle Trees'),
                _TechBadge(label: 'Polygon'),
                _TechBadge(label: 'IPFS'),
                _TechBadge(label: 'Zero-Knowledge'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TechBadge extends StatefulWidget {
  final String label;

  const _TechBadge({required this.label});

  @override
  State<_TechBadge> createState() => _TechBadgeState();
}

class _TechBadgeState extends State<_TechBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.neonGreen.withValues(alpha: 0.1) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: _isHovered ? AppColors.neonGreen.withValues(alpha: 0.5) : AppColors.cardBorder,
          ),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: AppColors.neonGreen.withValues(alpha: 0.2),
              blurRadius: 15,
            ),
          ] : null,
        ),
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: _isHovered ? AppColors.neonGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PipelineVisualization extends StatelessWidget {
  const _PipelineVisualization();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ContentContainer(
        maxWidth: 1000,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Text(
              'THE TRUST PIPELINE',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.electricBlue,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'From Document to Proof',
              style: textTheme.headlineMedium?.semiBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Pipeline visualization
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: isWide 
                  ? Row(
                      children: [
                        _PipelineStep(
                          step: '01',
                          icon: Icons.description_outlined,
                          label: 'Document',
                          color: AppColors.textSecondary,
                        ),
                        _PipelineArrow(),
                        _PipelineStep(
                          step: '02',
                          icon: Icons.fingerprint_rounded,
                          label: 'Hash',
                          color: AppColors.cyberPurple,
                        ),
                        _PipelineArrow(),
                        _PipelineStep(
                          step: '03',
                          icon: Icons.account_tree_rounded,
                          label: 'Merkle',
                          color: AppColors.warning,
                        ),
                        _PipelineArrow(),
                        _PipelineStep(
                          step: '04',
                          icon: Icons.link_rounded,
                          label: 'Blockchain',
                          color: AppColors.electricBlue,
                        ),
                        _PipelineArrow(),
                        _PipelineStep(
                          step: '05',
                          icon: Icons.qr_code_rounded,
                          label: 'Certificate',
                          color: AppColors.neonGreen,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _PipelineStepMobile(step: '01', icon: Icons.description_outlined, label: 'Document Input', color: AppColors.textSecondary),
                        _PipelineStepMobile(step: '02', icon: Icons.fingerprint_rounded, label: 'SHA-256 Hash', color: AppColors.cyberPurple),
                        _PipelineStepMobile(step: '03', icon: Icons.account_tree_rounded, label: 'Merkle Tree', color: AppColors.warning),
                        _PipelineStepMobile(step: '04', icon: Icons.link_rounded, label: 'Blockchain Anchor', color: AppColors.electricBlue),
                        _PipelineStepMobile(step: '05', icon: Icons.qr_code_rounded, label: 'Certificate', color: AppColors.neonGreen),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  final String step;
  final IconData icon;
  final String label;
  final Color color;

  const _PipelineStep({
    required this.step,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            step,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 40,
        child: DataFlowLine(
          width: 40,
          color: AppColors.neonGreen,
          duration: const Duration(milliseconds: 1200),
        ),
      ),
    );
  }
}

class _PipelineStepMobile extends StatelessWidget {
  final String step;
  final IconData icon;
  final String label;
  final Color color;

  const _PipelineStepMobile({
    required this.step,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= Breakpoints.tablet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.05),
            AppColors.electricBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ContentContainer(
        maxWidth: 1000,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Text(
              'TRUST AT SCALE',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.neonGreen,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            Wrap(
              spacing: isWide ? 64 : 32,
              runSpacing: 32,
              alignment: WrapAlignment.center,
              children: const [
                _StatItem(value: '10K+', label: 'Verifications', index: 0),
                _StatItem(value: '99.9%', label: 'Accuracy', index: 1),
                _StatItem(value: '<90s', label: 'Avg Time', index: 2),
                _StatItem(value: '0', label: 'Frauds', index: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatefulWidget {
  final String value;
  final String label;
  final int index;

  const _StatItem({required this.value, required this.label, this.index = 0});

  @override
  State<_StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<_StatItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: 200 * widget.index), () {
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
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.neonGradient.createShader(bounds),
                  child: GlitchText(
                    text: widget.value,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.cardBorder,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GlowingLogo(),
              const SizedBox(width: 12),
              Text(
                'TenantVerify',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Building India\'s Digital Trust Infrastructure',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 TenantVerify. Built for Dreamflow Buildathon.',
            style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
