import 'package:flutter/material.dart';
import 'package:project/theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool hasBorder;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool hasGlow;
  final Color glowColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.hasBorder = true,
    this.borderColor,
    this.onTap,
    this.hasGlow = false,
    this.glowColor = AppColors.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: hasBorder 
            ? Border.all(color: borderColor ?? AppColors.cardBorder)
            : null,
        boxShadow: hasGlow ? [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 20,
          ),
        ] : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: content,
        ),
      );
    }

    return content;
  }
}

class AppCardWithHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasGlow;
  final Color glowColor;

  const AppCardWithHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding,
    this.hasGlow = false,
    this.glowColor = AppColors.neonGreen,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: hasGlow ? [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 20,
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: textTheme.titleMedium?.semiBold),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColors.cardBorder,
          ),
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

class GlowCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final EdgeInsetsGeometry? padding;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.neonGreen,
    this.glowIntensity = 0.3,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: glowColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: glowIntensity),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final List<Color>? gradientColors;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [AppColors.neonGreen, AppColors.electricBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl - 2),
        ),
        child: child,
      ),
    );
  }
}
