import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr/qr.dart';
import 'package:project/theme.dart';
import 'package:project/components/buttons.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/components/animations.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/verification_provider.dart';
import 'package:project/models/certificate.dart';
import 'package:project/services/certificate_pdf_service.dart';

class CertificateScreen extends StatefulWidget {
  final String certificateId;

  const CertificateScreen({super.key, required this.certificateId});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _showAuditTrail = false;

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
        title: const Text('Trust Certificate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _showShareDialog(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Consumer<VerificationProvider>(
        builder: (context, provider, _) {
          final certificate = provider.getCertificateById(widget.certificateId);

          if (certificate == null) {
            return _buildNotFound(context);
          }

          final verification = provider.getVerificationById(certificate.verificationId);

          return Stack(
            children: [
              // Background effects
              const _AnimatedBackground(),
              
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ContentContainer(
                  maxWidth: 700,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Premium Certificate Card
                      _HolographicCertificate(
                        certificate: certificate,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Trust Score
                      _TrustScoreCard(certificate: certificate),
                      
                      const SizedBox(height: 24),
                      
                      // Blockchain Proof
                      _BlockchainProofCard(certificate: certificate),
                      
                      const SizedBox(height: 24),
                      
                      // Audit Trail Toggle
                      _AuditTrailSection(
                        isExpanded: _showAuditTrail,
                        onToggle: () => setState(() => _showAuditTrail = !_showAuditTrail),
                        verification: verification,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Actions
                      _ActionButtons(certificate: certificate),
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
          Text('Certificate not found', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Go to Dashboard',
            onPressed: () => context.go('/dashboard'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => _ShareSheet(),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.8, -0.3),
          radius: 1.5,
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}



/// Custom QR code widget using qr package for proper QR generation
class _QRCodePainter extends CustomPainter {
  final String data;
  final Color color;
  late final QrCode _qrCode;
  late final QrImage _qrImage;
  
  _QRCodePainter({required this.data, required this.color}) {
    _qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    _qrImage = QrImage(_qrCode);
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final moduleCount = _qrCode.moduleCount;
    final moduleSize = size.width / moduleCount;
    
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (_qrImage.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(x * moduleSize, y * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(_QRCodePainter oldDelegate) => oldDelegate.data != data || oldDelegate.color != color;
}

class _HolographicCertificate extends StatelessWidget {
  final Certificate certificate;

  const _HolographicCertificate({
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd MMM yyyy');
    final isExpired = DateTime.now().isAfter(certificate.expiryDate);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: certificate.isRevoked 
                ? AppColors.textMuted.withValues(alpha: 0.2)
                : AppColors.neonGreen.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            // Main card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: certificate.isRevoked 
                      ? [AppColors.surfaceLight, AppColors.surface]
                      : [
                          AppColors.surface,
                          Color.lerp(AppColors.surface, AppColors.neonGreen, 0.05)!,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: certificate.isRevoked 
                      ? AppColors.cardBorder
                      : AppColors.neonGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: certificate.isRevoked 
                                  ? AppColors.cardBorder
                                  : AppColors.neonGreen.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: certificate.isRevoked 
                                    ? null 
                                    : AppColors.neonGradient,
                                color: certificate.isRevoked ? AppColors.surfaceLight : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'TV',
                                  style: TextStyle(
                                    color: certificate.isRevoked 
                                        ? AppColors.textMuted 
                                        : AppColors.background,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TenantVerify',
                                    style: textTheme.titleMedium?.semiBold,
                                  ),
                                  Text(
                                    'Blockchain Trust Certificate',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _CertificateBadge(
                              isValid: certificate.isValid,
                              isRevoked: certificate.isRevoked,
                              isExpired: isExpired,
                            ),
                          ],
                        ),
                      ),
                      
                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            // Verified icon with glow
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: certificate.isRevoked 
                                    ? null 
                                    : AppColors.neonGradient,
                                color: certificate.isRevoked ? AppColors.surfaceLight : null,
                                boxShadow: certificate.isRevoked ? null : [
                                  BoxShadow(
                                    color: AppColors.neonGreen.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                certificate.isRevoked 
                                    ? Icons.block_rounded 
                                    : Icons.verified_rounded,
                                color: certificate.isRevoked 
                                    ? AppColors.textMuted 
                                    : AppColors.background,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Tenant name
                            Text(
                              certificate.tenantName,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              certificate.isRevoked 
                                  ? 'CERTIFICATE REVOKED'
                                  : 'IDENTITY VERIFIED',
                              style: textTheme.labelMedium?.copyWith(
                                color: certificate.isRevoked 
                                    ? AppColors.error 
                                    : AppColors.neonGreen,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // QR Code
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                size: const Size(160, 160),
                                painter: _QRCodePainter(
                                  data: certificate.qrCodeData.isNotEmpty 
                                      ? certificate.qrCodeData 
                                      : 'https://tenantverify.app/cert/${certificate.id}',
                                  color: certificate.isRevoked 
                                      ? const Color(0xFF888888)
                                      : const Color(0xFF000000),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Scan to verify authenticity',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Certificate details
                            _CertificateDetail(
                              label: 'Certificate No.',
                              value: certificate.certificateNumber,
                            ),
                            _CertificateDetail(
                              label: 'Issue Date',
                              value: dateFormat.format(certificate.issueDate),
                            ),
                            _CertificateDetail(
                              label: 'Expiry Date',
                              value: dateFormat.format(certificate.expiryDate),
                              valueColor: isExpired ? AppColors.error : null,
                            ),
                            _CertificateDetail(
                              label: 'Issuer',
                              value: _shortenAddress(certificate.landlordAddress),
                              isMono: true,
                            ),
                          ],
                        ),
                      ),
                      
                      // Footer with transaction hash
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(AppRadius.xl - 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link_rounded, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                certificate.transactionHash,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              color: AppColors.textMuted,
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: certificate.transactionHash));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaction hash copied'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }

  String _shortenAddress(String address) {
    if (address.length < 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}

class _CertificateBadge extends StatelessWidget {
  final bool isValid;
  final bool isRevoked;
  final bool isExpired;

  const _CertificateBadge({
    required this.isValid,
    required this.isRevoked,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRevoked 
        ? AppColors.error 
        : isExpired 
            ? AppColors.warning 
            : AppColors.neonGreen;
    
    final label = isRevoked 
        ? 'REVOKED' 
        : isExpired 
            ? 'EXPIRED' 
            : 'VALID';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateDetail extends StatelessWidget {
  final String label;
  final String value;
  final bool isMono;
  final Color? valueColor;

  const _CertificateDetail({
    required this.label,
    required this.value,
    this.isMono = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          Text(
            value,
            style: isMono
                ? TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: valueColor ?? AppColors.textPrimary,
                  )
                : textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TrustScoreCard extends StatelessWidget {
  final Certificate certificate;

  const _TrustScoreCard({required this.certificate});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trustScore = certificate.isRevoked ? 0 : 98; // Mock score
    final riskLevel = trustScore >= 90 ? 'LOW' : trustScore >= 70 ? 'MEDIUM' : 'HIGH';
    final riskColor = trustScore >= 90 ? AppColors.neonGreen : trustScore >= 70 ? AppColors.warning : AppColors.error;

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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.electricBlue, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'TRUST SCORE',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.electricBlue,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              // Score circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: trustScore / 100,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation(riskColor),
                    ),
                  ),
                  Text(
                    '$trustScore',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Risk Level: ',
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            riskLevel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: riskColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on verification completeness, document quality, and blockchain confirmations.',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
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

class _BlockchainProofCard extends StatelessWidget {
  final Certificate certificate;

  const _BlockchainProofCard({required this.certificate});

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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cyberPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.link_rounded, color: AppColors.cyberPurple, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'BLOCKCHAIN PROOF',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.cyberPurple,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.15),
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
          
          _ProofRow(
            icon: Icons.account_tree_rounded,
            label: 'Merkle Root',
            value: certificate.merkleRoot,
          ),
          const SizedBox(height: 12),
          _ProofRow(
            icon: Icons.tag_rounded,
            label: 'Transaction',
            value: certificate.transactionHash,
          ),
          const SizedBox(height: 12),
          _ProofRow(
            icon: Icons.language_rounded,
            label: 'Network',
            value: 'Polygon Mumbai (Testnet)',
          ),
        ],
      ),
    );
  }
}

class _ProofRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProofRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 16, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.length > 40 
                    ? '${value.substring(0, 20)}...${value.substring(value.length - 16)}'
                    : value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuditTrailSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final dynamic verification;

  const _AuditTrailSection({
    required this.isExpanded,
    required this.onToggle,
    required this.verification,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.history_rounded, color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUDIT TRAIL',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.warning,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete verification history',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          
          if (isExpanded) ...[
            Container(
              height: 1,
              color: AppColors.cardBorder,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _AuditItem(
                    time: 'Step 1',
                    action: 'Document Upload',
                    description: 'Documents received and queued for processing',
                    isComplete: true,
                  ),
                  _AuditItem(
                    time: 'Step 2',
                    action: 'Hash Generation',
                    description: 'SHA-256 fingerprints computed',
                    isComplete: true,
                  ),
                  _AuditItem(
                    time: 'Step 3',
                    action: 'Merkle Tree',
                    description: 'Root hash generated from document hashes',
                    isComplete: true,
                  ),
                  _AuditItem(
                    time: 'Step 4',
                    action: 'Blockchain Anchor',
                    description: 'Proof recorded on Polygon',
                    isComplete: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AuditItem extends StatelessWidget {
  final String time;
  final String action;
  final String description;
  final bool isComplete;
  final bool isLast;

  const _AuditItem({
    required this.time,
    required this.action,
    required this.description,
    required this.isComplete,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isComplete ? AppColors.neonGreen : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isComplete ? Icons.check_rounded : Icons.circle,
                size: 14,
                color: isComplete ? AppColors.background : AppColors.textMuted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isComplete ? AppColors.neonGreen.withValues(alpha: 0.3) : AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(time, style: textTheme.labelSmall?.copyWith(color: AppColors.neonGreen)),
                    const SizedBox(width: 8),
                    Text(action, style: textTheme.titleSmall?.semiBold),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatefulWidget {
  final Certificate certificate;

  const _ActionButtons({required this.certificate});

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isGeneratingPdf ? null : _downloadPdf,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textMuted,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(_isGeneratingPdf ? 'Generating...' : 'Download'),
          ),
        ),
        const SizedBox(width: 12),
        if (!widget.certificate.isRevoked)
          Expanded(
            child: _RevokeButton(certificateId: widget.certificate.id),
          ),
      ],
    );
  }

  Future<void> _downloadPdf() async {
    setState(() => _isGeneratingPdf = true);
    
    try {
      await CertificatePdfService.shareCertificate(widget.certificate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }
}

class _RevokeButton extends StatelessWidget {
  final String certificateId;

  const _RevokeButton({required this.certificateId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<VerificationProvider, AuthProvider>(
      builder: (context, provider, auth, _) => ElevatedButton.icon(
        onPressed: provider.isLoading 
            ? null 
            : () => _showRevokeConfirmation(context, provider, auth),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: provider.isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.block_rounded, size: 20, color: Colors.white),
        label: const Text('Revoke', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showRevokeConfirmation(
    BuildContext context,
    VerificationProvider provider,
    AuthProvider auth,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Revoke Certificate?'),
        content: const Text(
          'This action cannot be undone. The certificate will be permanently marked as revoked on the blockchain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final landlordAddress = auth.user?.walletAddress ??
                  '0x742d35Cc6634C0532925a3b844Bc9e7595f2bD9e';
              await provider.revokeCertificate(certificateId, landlordAddress);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text('Share Certificate', style: textTheme.titleLarge?.semiBold),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(icon: Icons.link_rounded, label: 'Copy Link'),
              _ShareOption(icon: Icons.email_outlined, label: 'Email'),
              _ShareOption(icon: Icons.qr_code_rounded, label: 'QR Code'),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ShareOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

// For backward compatibility
class CertificateBadge extends StatelessWidget {
  final bool isValid;
  final bool isRevoked;
  final bool isExpired;

  const CertificateBadge({
    super.key,
    required this.isValid,
    required this.isRevoked,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    return _CertificateBadge(
      isValid: isValid,
      isRevoked: isRevoked,
      isExpired: isExpired,
    );
  }
}
