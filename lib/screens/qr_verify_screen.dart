import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/providers/verification_provider.dart';
import 'package:project/models/certificate.dart';

class QrVerifyScreen extends StatefulWidget {
  final String? certificateId;

  const QrVerifyScreen({super.key, this.certificateId});

  @override
  State<QrVerifyScreen> createState() => _QrVerifyScreenState();
}

class _QrVerifyScreenState extends State<QrVerifyScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _isFailed = false;
  Certificate? _verifiedCertificate;
  final _manualCodeController = TextEditingController();
  bool _showManualEntry = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Auto-verify if certificateId is provided
    if (widget.certificateId != null) {
      Future.delayed(const Duration(milliseconds: 500), () => _startVerification(widget.certificateId));
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  Future<void> _startVerification(String? certId) async {
    if (certId == null || certId.isEmpty) {
      setState(() {
        _isFailed = true;
        _isVerifying = false;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _isVerified = false;
      _isFailed = false;
      _verifiedCertificate = null;
    });

    // Simulate blockchain verification
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      final provider = context.read<VerificationProvider>();
      final certificate = provider.getCertificateById(certId);
      
      if (certificate != null && !certificate.isRevoked) {
        setState(() {
          _isVerifying = false;
          _isVerified = true;
          _verifiedCertificate = certificate;
        });
      } else {
        setState(() {
          _isVerifying = false;
          _isFailed = true;
        });
      }
    }
  }

  void _simulateScanWithSampleData() {
    // Get a random sample certificate from the provider
    final provider = context.read<VerificationProvider>();
    final certificates = provider.certificates.where((c) => !c.isRevoked).toList();
    
    if (certificates.isNotEmpty) {
      final randomCert = certificates[math.Random().nextInt(certificates.length)];
      _startVerification(randomCert.id);
    } else {
      setState(() {
        _isFailed = true;
      });
    }
  }

  void _verifyManualCode() {
    final code = _manualCodeController.text.trim();
    if (code.isEmpty) return;
    
    // Try to find certificate by ID or certificate number
    final provider = context.read<VerificationProvider>();
    final certificates = provider.certificates;
    
    Certificate? found;
    for (final cert in certificates) {
      if (cert.id == code || 
          cert.certificateNumber.toLowerCase() == code.toLowerCase() ||
          cert.verificationId == code) {
        found = cert;
        break;
      }
    }
    
    if (found != null) {
      _startVerification(found.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate not found. Please check the code and try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Verify Certificate'),
        actions: [
          IconButton(
            icon: Icon(_showManualEntry ? Icons.qr_code_scanner_rounded : Icons.keyboard_rounded),
            onPressed: () => setState(() {
              _showManualEntry = !_showManualEntry;
              _isVerifying = false;
              _isVerified = false;
              _isFailed = false;
            }),
            tooltip: _showManualEntry ? 'Scan QR' : 'Manual Entry',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          _AnimatedBackground(controller: _scanController),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ContentContainer(
              maxWidth: 500,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  if (_isVerifying)
                    _VerifyingState(
                      scanController: _scanController,
                      pulseController: _pulseController,
                    )
                  else if (_isVerified && _verifiedCertificate != null)
                    _VerifiedState(certificate: _verifiedCertificate!)
                  else if (_isFailed)
                    _FailedState(onRetry: () {
                      setState(() {
                        _isFailed = false;
                        _manualCodeController.clear();
                      });
                    })
                  else if (_showManualEntry)
                    _ManualEntryState(
                      controller: _manualCodeController,
                      onVerify: _verifyManualCode,
                    )
                  else
                    _ScanState(
                      onScan: _simulateScanWithSampleData,
                      pulseController: _pulseController,
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

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GridPainter(progress: controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final double progress;

  _GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cardBorder.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      final offset = math.sin((x / size.width + progress) * math.pi * 2) * 5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + offset, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.progress != progress;
}

class _ScanState extends StatelessWidget {
  final VoidCallback onScan;
  final AnimationController pulseController;

  const _ScanState({
    required this.onScan,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Scanner frame
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            return Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: AppColors.neonGreen.withValues(
                    alpha: 0.3 + 0.2 * pulseController.value,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(
                      alpha: 0.1 + 0.1 * pulseController.value,
                    ),
                    blurRadius: 30,
                    spreadRadius: 5 * pulseController.value,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 48,
                      color: AppColors.neonGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Position QR Code Here',
                    style: textTheme.titleSmall?.semiBold,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Align the certificate QR code\nwithin the frame',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.cardBorder),
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
                child: const Icon(Icons.info_outline_rounded, color: AppColors.electricBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Mode',
                      style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Camera scanning requires device access. Tap below to simulate verification.',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Scan button
        Container(
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
            onPressed: onScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text(
              'Simulate QR Scan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Or tap the keyboard icon above for manual entry',
          style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}



class _ManualEntryState extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onVerify;

  const _ManualEntryState({
    required this.controller,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
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
              color: AppColors.electricBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.keyboard_rounded,
              size: 40,
              color: AppColors.electricBlue,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Manual Verification',
            style: textTheme.titleLarge?.semiBold,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the certificate ID or number to verify',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: 'e.g., TV-2025-XXXXXXXX',
              hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.verified_user_outlined, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.neonGreen),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onVerify(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Verify Certificate', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyingState extends StatelessWidget {
  final AnimationController scanController;
  final AnimationController pulseController;

  const _VerifyingState({
    required this.scanController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Animated verification
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              AnimatedBuilder(
                animation: scanController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: scanController.value * math.pi * 2,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.electricBlue.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _ArcPainter(progress: scanController.value),
                      ),
                    ),
                  );
                },
              ),
              // Inner pulse
              AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Container(
                    width: 120 + 10 * pulseController.value,
                    height: 120 + 10 * pulseController.value,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      size: 48,
                      color: AppColors.electricBlue,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Verifying on Blockchain',
          style: textTheme.titleLarge?.semiBold,
        ),
        const SizedBox(height: 12),

        // Progress steps
        _VerifyStep(label: 'Extracting certificate data...', isActive: true),
        _VerifyStep(label: 'Querying Polygon network...', isActive: true),
        _VerifyStep(label: 'Comparing Merkle proofs...', isActive: false),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;

  _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.electricBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.progress != progress;
}

class _VerifyStep extends StatelessWidget {
  final String label;
  final bool isActive;

  const _VerifyStep({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.electricBlue),
              ),
            )
          else
            Icon(Icons.circle_outlined, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedState extends StatelessWidget {
  final Certificate certificate;

  const _VerifiedState({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.2),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 56,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'CERTIFICATE VERIFIED',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.neonGreen,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            certificate.tenantName,
            style: textTheme.titleLarge?.semiBold,
          ),
          const SizedBox(height: 8),
          Text(
            'This certificate is authentic and valid',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Verification details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.badge_rounded,
                  label: 'Certificate',
                  value: certificate.certificateNumber,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.check_circle_rounded,
                  label: 'Merkle Proof',
                  value: 'Valid',
                  color: AppColors.neonGreen,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.link_rounded,
                  label: 'Blockchain',
                  value: 'Confirmed',
                  color: AppColors.neonGreen,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Valid Until',
                  value: '${certificate.expiryDate.day}/${certificate.expiryDate.month}/${certificate.expiryDate.year}',
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/dashboard'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Done'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.go('/certificate/${certificate.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FailedState extends StatelessWidget {
  final VoidCallback onRetry;

  const _FailedState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_rounded,
              size: 56,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'VERIFICATION FAILED',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.error,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Certificate Not Found',
            style: textTheme.titleLarge?.semiBold,
          ),
          const SizedBox(height: 8),
          Text(
            'This certificate could not be verified.\nIt may be invalid, revoked, or tampered with.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/dashboard'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
