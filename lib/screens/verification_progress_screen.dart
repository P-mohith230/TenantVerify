import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/app_card.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';
import 'package:project/providers/verification_provider.dart';
import 'package:project/models/verification.dart';

class VerificationProgressScreen extends StatefulWidget {
  final String verificationId;

  const VerificationProgressScreen({super.key, required this.verificationId});

  @override
  State<VerificationProgressScreen> createState() => _VerificationProgressScreenState();
}

class _VerificationProgressScreenState extends State<VerificationProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _waveController;
  bool _isTechnicalView = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Verification Engine'),
        actions: [
          // View mode toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewToggle(
                  label: 'Simple',
                  isActive: !_isTechnicalView,
                  onTap: () => setState(() => _isTechnicalView = false),
                ),
                _ViewToggle(
                  label: 'Technical',
                  isActive: _isTechnicalView,
                  onTap: () => setState(() => _isTechnicalView = true),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<VerificationProvider>(
        builder: (context, provider, _) {
          final verification = provider.getVerificationById(widget.verificationId) ??
                               provider.currentVerification;

          if (verification == null) {
            return _buildNotFound(context);
          }

          final tenant = provider.getTenantById(verification.tenantId);
          final certificate = provider.getCertificateForTenant(verification.tenantId);
          final isComplete = verification.status == VerificationStatus.verified;
          final isFailed = verification.status == VerificationStatus.failed;

          return Stack(
            children: [
              // Animated background
              _AnimatedBackground(controller: _waveController),
              
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ContentContainer(
                  maxWidth: 900,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status header
                      _StatusHeader(
                        tenantName: tenant?.name ?? 'Unknown',
                        status: verification.status,
                        pulseController: _pulseController,
                      ),
                      const SizedBox(height: 32),
                      
                      // Main visualization
                      if (_isTechnicalView)
                        _TechnicalView(
                          verification: verification,
                          rotateController: _rotateController,
                        )
                      else
                        _SimpleView(
                          verification: verification,
                          pulseController: _pulseController,
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Pipeline visualization
                      _PipelineProgress(
                        steps: verification.steps,
                        isTechnical: _isTechnicalView,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Blockchain proof (if complete)
                      if (isComplete && verification.merkleRoot != null)
                        _BlockchainProof(
                          merkleRoot: verification.merkleRoot!,
                          transactionHash: verification.transactionHash ?? '',
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Actions
                      _ActionButtons(
                        isComplete: isComplete,
                        isFailed: isFailed,
                        certificate: certificate,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Verification not found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Go to Dashboard',
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.neonGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.background : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(progress: controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;

  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.neonGreen.withValues(alpha: 0.05),
          AppColors.electricBlue.withValues(alpha: 0.03),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height - 100 + 
          math.sin((x / waveLength * math.pi * 2) + (progress * math.pi * 2)) * waveHeight;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.progress != progress;
}

class _StatusHeader extends StatelessWidget {
  final String tenantName;
  final VerificationStatus status;
  final AnimationController pulseController;

  const _StatusHeader({
    required this.tenantName,
    required this.status,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isProcessing = status == VerificationStatus.processing || 
                         status == VerificationStatus.pending;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
        ),
        boxShadow: isProcessing ? [
          BoxShadow(
            color: _getStatusColor(status).withValues(alpha: 0.2),
            blurRadius: 30,
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Animated status icon
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: isProcessing ? [
                    BoxShadow(
                      color: _getStatusColor(status).withValues(
                        alpha: 0.3 * pulseController.value,
                      ),
                      blurRadius: 20,
                      spreadRadius: 5 * pulseController.value,
                    ),
                  ] : null,
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tenantName, style: textTheme.titleLarge?.semiBold),
                const SizedBox(height: 4),
                Text(
                  _getStatusMessage(status),
                  style: textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(status),
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(status: status),
        ],
      ),
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

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.schedule_rounded;
      case VerificationStatus.processing:
        return Icons.autorenew_rounded;
      case VerificationStatus.verified:
        return Icons.verified_rounded;
      case VerificationStatus.failed:
        return Icons.error_outline_rounded;
      case VerificationStatus.revoked:
        return Icons.block_rounded;
    }
  }

  String _getStatusMessage(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Preparing verification engine...';
      case VerificationStatus.processing:
        return 'Transforming documents into cryptographic proof...';
      case VerificationStatus.verified:
        return 'All documents verified • Proof anchored on blockchain';
      case VerificationStatus.failed:
        return 'Verification failed • Please retry';
      case VerificationStatus.revoked:
        return 'Certificate has been revoked';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final VerificationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getColor() {
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

  String _getLabel() {
    switch (status) {
      case VerificationStatus.pending:
        return 'PENDING';
      case VerificationStatus.processing:
        return 'PROCESSING';
      case VerificationStatus.verified:
        return 'VERIFIED';
      case VerificationStatus.failed:
        return 'FAILED';
      case VerificationStatus.revoked:
        return 'REVOKED';
    }
  }
}

class _SimpleView extends StatelessWidget {
  final Verification verification;
  final AnimationController pulseController;

  const _SimpleView({
    required this.verification,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completedSteps = verification.steps.where((s) => s.isCompleted).length;
    final totalSteps = verification.steps.length;
    final progress = completedSteps / totalSteps;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Circular progress
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(
                            alpha: 0.2 * pulseController.value,
                          ),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation(AppColors.neonGreen),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonGreen,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Current step description
          if (completedSteps < totalSteps)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.sync_rounded,
                      color: AppColors.electricBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          verification.steps[completedSteps].title,
                          style: textTheme.titleSmall?.semiBold,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStepDescription(completedSteps),
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
        ],
      ),
    );
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Generating cryptographic fingerprints of your documents...';
      case 1:
        return 'Building Merkle tree from document hashes...';
      case 2:
        return 'Verifying documents with government APIs...';
      case 3:
        return 'Recording immutable proof on Polygon blockchain...';
      default:
        return 'Processing...';
    }
  }
}

class _TechnicalView extends StatelessWidget {
  final Verification verification;
  final AnimationController rotateController;

  const _TechnicalView({
    required this.verification,
    required this.rotateController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.terminal_rounded, color: AppColors.neonGreen, size: 20),
              const SizedBox(width: 12),
              Text(
                'VERIFICATION ENGINE OUTPUT',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.neonGreen,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Merkle Tree Visualization
          if (verification.merkleRoot != null) ...[
            _MerkleTreeVisualization(
              merkleRoot: verification.merkleRoot!,
              rotateController: rotateController,
            ),
            const SizedBox(height: 24),
          ],
          
          // Technical logs
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final step in verification.steps)
                  _TechnicalLogLine(step: step),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MerkleTreeVisualization extends StatelessWidget {
  final String merkleRoot;
  final AnimationController rotateController;

  const _MerkleTreeVisualization({
    required this.merkleRoot,
    required this.rotateController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'MERKLE ROOT',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.neonGreen,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree visualization
          AnimatedBuilder(
            animation: rotateController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(200, 100),
                painter: _MerkleTreePainter(
                  progress: rotateController.value,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Root hash
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tag_rounded, color: AppColors.neonGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  merkleRoot.length > 20 
                      ? '${merkleRoot.substring(0, 10)}...${merkleRoot.substring(merkleRoot.length - 8)}'
                      : merkleRoot,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.neonGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MerkleTreePainter extends CustomPainter {
  final double progress;

  _MerkleTreePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonGreen.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = AppColors.neonGreen
      ..style = PaintingStyle.fill;

    // Draw tree structure
    final centerX = size.width / 2;
    
    // Level 1 (root)
    canvas.drawCircle(Offset(centerX, 10), 6, nodePaint);
    
    // Lines to level 2
    canvas.drawLine(Offset(centerX, 16), Offset(centerX - 50, 44), paint);
    canvas.drawLine(Offset(centerX, 16), Offset(centerX + 50, 44), paint);
    
    // Level 2
    canvas.drawCircle(Offset(centerX - 50, 50), 5, nodePaint);
    canvas.drawCircle(Offset(centerX + 50, 50), 5, nodePaint);
    
    // Lines to level 3
    canvas.drawLine(Offset(centerX - 50, 55), Offset(centerX - 75, 84), paint);
    canvas.drawLine(Offset(centerX - 50, 55), Offset(centerX - 25, 84), paint);
    canvas.drawLine(Offset(centerX + 50, 55), Offset(centerX + 25, 84), paint);
    canvas.drawLine(Offset(centerX + 50, 55), Offset(centerX + 75, 84), paint);
    
    // Level 3 (leaves)
    final leafPositions = [
      Offset(centerX - 75, 90),
      Offset(centerX - 25, 90),
      Offset(centerX + 25, 90),
      Offset(centerX + 75, 90),
    ];
    
    for (final pos in leafPositions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: 16, height: 12),
          const Radius.circular(3),
        ),
        nodePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MerkleTreePainter oldDelegate) => false;
}

class _TechnicalLogLine extends StatelessWidget {
  final VerificationStep step;

  const _TechnicalLogLine({required this.step});

  @override
  Widget build(BuildContext context) {
    final isComplete = step.isCompleted;
    final isFailed = step.isFailed;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '> ',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isComplete 
                  ? AppColors.neonGreen 
                  : isFailed 
                      ? AppColors.error 
                      : AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: step.title,
                    style: TextStyle(
                      color: isComplete 
                          ? AppColors.textPrimary 
                          : AppColors.textMuted,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  if (isComplete)
                    TextSpan(
                      text: '✓ ${step.result ?? "Success"}',
                      style: const TextStyle(color: AppColors.neonGreen),
                    )
                  else if (isFailed)
                    TextSpan(
                      text: '✗ ${step.result ?? "Failed"}',
                      style: const TextStyle(color: AppColors.error),
                    )
                  else
                    const TextSpan(
                      text: '⋯',
                      style: TextStyle(color: AppColors.textMuted),
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

class _PipelineProgress extends StatelessWidget {
  final List<VerificationStep> steps;
  final bool isTechnical;

  const _PipelineProgress({
    required this.steps,
    required this.isTechnical,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTechnical ? 'EXECUTION PIPELINE' : 'Verification Steps',
            style: isTechnical 
                ? textTheme.labelSmall?.copyWith(
                    color: AppColors.electricBlue,
                    letterSpacing: 2,
                  )
                : textTheme.titleMedium?.semiBold,
          ),
          const SizedBox(height: 20),
          
          for (int i = 0; i < steps.length; i++) ...[
            _PipelineStepItem(
              step: steps[i],
              index: i,
              isLast: i == steps.length - 1,
              isTechnical: isTechnical,
            ),
          ],
        ],
      ),
    );
  }
}

class _PipelineStepItem extends StatelessWidget {
  final VerificationStep step;
  final int index;
  final bool isLast;
  final bool isTechnical;

  const _PipelineStepItem({
    required this.step,
    required this.index,
    required this.isLast,
    required this.isTechnical,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isComplete = step.isCompleted;
    final isFailed = step.isFailed;
    final color = isComplete 
        ? AppColors.neonGreen 
        : isFailed 
            ? AppColors.error 
            : AppColors.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isComplete ? 1 : 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                isComplete 
                    ? Icons.check_rounded 
                    : isFailed 
                        ? Icons.close_rounded 
                        : Icons.circle,
                color: isComplete ? AppColors.background : color,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isComplete ? AppColors.neonGreen : AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: textTheme.titleSmall?.copyWith(
                    color: isComplete ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                if (step.result != null && isTechnical) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.result!.length > 50 
                        ? '${step.result!.substring(0, 50)}...'
                        : step.result!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BlockchainProof extends StatelessWidget {
  final String merkleRoot;
  final String transactionHash;

  const _BlockchainProof({
    required this.merkleRoot,
    required this.transactionHash,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.1),
            AppColors.electricBlue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.link_rounded, color: AppColors.background, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'BLOCKCHAIN PROOF',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.neonGreen,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text(
                  'IMMUTABLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neonGreen,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _ProofDataRow(label: 'Merkle Root', value: merkleRoot),
          const SizedBox(height: 12),
          _ProofDataRow(label: 'Transaction', value: transactionHash),
          const SizedBox(height: 12),
          _ProofDataRow(label: 'Network', value: 'Polygon Mumbai (Testnet)'),
        ],
      ),
    );
  }
}

class _ProofDataRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProofDataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.length > 40 
                ? '${value.substring(0, 20)}...${value.substring(value.length - 16)}'
                : value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isComplete;
  final bool isFailed;
  final dynamic certificate;

  const _ActionButtons({
    required this.isComplete,
    required this.isFailed,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    if (isComplete && certificate != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGreen.withValues(alpha: 0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => context.push('/certificate/${certificate.id}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonGreen,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.workspace_premium_rounded),
          label: const Text(
            'View Certificate',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (isFailed) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.go('/dashboard'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Dashboard'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.go('/verify'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    // Processing state
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.electricBlue),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Processing verification...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
