import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'package:project/models/verification.dart';

class WizardStepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const WizardStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentStep;
          
          return Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? AppColors.neonGradient
                    : null,
                color: isCompleted ? null : AppColors.cardBorder,
              ),
            ),
          );
        }
        
        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        final color = isCompleted || isCurrent ? AppColors.neonGreen : AppColors.textMuted;

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.neonGreen
                    : isCurrent
                        ? AppColors.neonGreen.withValues(alpha: 0.2)
                        : AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || isCurrent ? AppColors.neonGreen : AppColors.cardBorder,
                  width: 2,
                ),
                boxShadow: isCompleted || isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, size: 16, color: AppColors.background)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCurrent ? AppColors.neonGreen : AppColors.textMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              steps[stepIndex],
              style: textTheme.labelSmall?.copyWith(
                color: isCompleted || isCurrent ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class StepTimeline extends StatelessWidget {
  final List<VerificationStep> steps;
  final int currentStep;

  const StepTimeline({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = step.isCompleted;
        final isFailed = step.isFailed;
        final isCurrent = index == currentStep && !isCompleted && !isFailed;
        final isLast = index == steps.length - 1;

        final color = isCompleted
            ? AppColors.neonGreen
            : isFailed
                ? AppColors.error
                : isCurrent
                    ? AppColors.electricBlue
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
                    color: isCompleted
                        ? color
                        : isCurrent
                            ? color.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                    boxShadow: isCompleted || isCurrent
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.background,
                          )
                        : isFailed
                            ? Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppColors.error,
                              )
                            : isCurrent
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(color),
                                    ),
                                  )
                                : Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: AppColors.textMuted,
                                  ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? AppColors.neonGreen : AppColors.cardBorder,
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
                        color: isCompleted || isCurrent
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontWeight:
                            isCompleted || isCurrent ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    if (step.result != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.result!.length > 60
                            ? '${step.result!.substring(0, 60)}...'
                            : step.result!,
                        style: textTheme.bodySmall?.copyWith(
                          color: color,
                          fontFamily: step.result!.startsWith('0x') ? 'monospace' : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
