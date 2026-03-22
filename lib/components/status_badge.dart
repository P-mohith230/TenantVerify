import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'package:project/models/verification.dart';

class StatusBadge extends StatelessWidget {
  final VerificationStatus status;
  final bool showIcon;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final label = _getLabel();
    final icon = _getIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 10,
        vertical: isLarge ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isLarge ? 8 : 6,
            height: isLarge ? 8 : 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          SizedBox(width: isLarge ? 10 : 8),
          if (showIcon) ...[
            Icon(icon, size: isLarge ? 16 : 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
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

  IconData _getIcon() {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.schedule_rounded;
      case VerificationStatus.processing:
        return Icons.sync_rounded;
      case VerificationStatus.verified:
        return Icons.verified_rounded;
      case VerificationStatus.failed:
        return Icons.error_rounded;
      case VerificationStatus.revoked:
        return Icons.block_rounded;
    }
  }
}

class GlowingStatusIndicator extends StatefulWidget {
  final VerificationStatus status;
  final double size;

  const GlowingStatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
  });

  @override
  State<GlowingStatusIndicator> createState() => _GlowingStatusIndicatorState();
}

class _GlowingStatusIndicatorState extends State<GlowingStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    if (widget.status == VerificationStatus.processing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(
                  alpha: widget.status == VerificationStatus.processing
                      ? 0.3 + 0.4 * _controller.value
                      : 0.5,
                ),
                blurRadius: widget.status == VerificationStatus.processing
                    ? 8 + 8 * _controller.value
                    : 8,
                spreadRadius: widget.status == VerificationStatus.processing
                    ? 2 * _controller.value
                    : 0,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor() {
    switch (widget.status) {
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
}
