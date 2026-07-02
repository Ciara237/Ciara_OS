import 'package:ciaraos/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Compact header with a single back control — no drawer avatar or app chrome.
class MinimalBackHeader extends StatelessWidget {
  const MinimalBackHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: AppSpacing.appBarHeight,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: onBack ?? () => context.pop(),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          tooltip: 'Back',
        ),
      ),
    );
  }
}
