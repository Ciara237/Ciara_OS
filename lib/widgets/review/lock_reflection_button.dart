import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class LockReflectionButton extends StatelessWidget {
  const LockReflectionButton({
    super.key,
    required this.onLock,
  });

  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onLock,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: Text(
            'LOCK WEEKLY REFLECTION →',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Finalizing this action will sync data to long-term memory archive.',
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
