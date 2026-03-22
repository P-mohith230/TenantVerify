import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/theme.dart';
import 'package:project/models/tenant.dart';
import 'package:project/models/verification.dart';

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final VerificationStatus? status;
  final bool hasCertificate;
  final DateTime? verificationDate;
  final VoidCallback? onTap;

  const TenantCard({
    super.key,
    required this.tenant,
    this.status,
    this.hasCertificate = false,
    this.verificationDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusColor = _getStatusColor();

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
            border: Border.all(
              color: status == VerificationStatus.verified 
                  ? AppColors.neonGreen.withValues(alpha: 0.2)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              // Avatar with status indicator
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Center(
                      child: Text(
                        tenant.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  if (hasCertificate)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonGreen.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tenant.name,
                            style: textTheme.titleSmall?.semiBold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (status != null)
                          _StatusChip(status: status!),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tenant.email,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (verificationDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(verificationDate!),
                            style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
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
      default:
        return AppColors.textMuted;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final VerificationStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final label = _getLabel();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
