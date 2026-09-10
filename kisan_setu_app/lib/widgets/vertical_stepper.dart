import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum StepState { completed, active, pending }

class StepperItemData {
  final String title;
  final String? subtitle;
  final String? timeOrStatus;
  final IconData? icon;
  final StepState state;

  const StepperItemData({
    required this.title,
    this.subtitle,
    this.timeOrStatus,
    this.icon,
    required this.state,
  });
}

class VerticalProgressStepper extends StatelessWidget {
  final List<StepperItemData> steps;

  const VerticalProgressStepper({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Node & Line column
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    // Node
                    _buildNode(step, index + 1),
                    // Connecting line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 4,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: step.state == StepState.completed
                              ? AppColors.primaryContainer
                              : AppColors.surfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    bottom: isLast ? 8 : 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: step.state == StepState.active
                            ? AppTypography.headlineSmall(color: AppColors.onSurface)
                            : (step.state == StepState.completed
                                ? AppTypography.labelLarge(color: AppColors.onSurface)
                                : AppTypography.bodyLarge(color: AppColors.onSurfaceVariant)),
                      ),
                      if (step.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle!,
                          style: AppTypography.bodySmall(
                            color: step.state == StepState.active
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (step.timeOrStatus != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          step.timeOrStatus!,
                          style: AppTypography.labelMedium(
                            color: step.state == StepState.active
                                ? AppColors.secondary
                                : AppColors.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNode(StepperItemData step, int stepNumber) {
    switch (step.state) {
      case StepState.completed:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBright, width: 3),
          ),
          child: const Icon(
            Icons.check,
            size: 16,
            color: AppColors.onPrimary,
          ),
        );
      case StepState.active:
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBright, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryContainer.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            step.icon ?? Icons.science,
            size: 20,
            color: AppColors.onSecondaryContainer,
          ),
        );
      case StepState.pending:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBright, width: 3),
          ),
          child: Icon(
            step.icon ?? Icons.circle_outlined,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
        );
    }
  }
}
