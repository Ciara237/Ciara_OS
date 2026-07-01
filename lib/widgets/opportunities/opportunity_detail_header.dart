import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OpportunityDetailHeader extends StatelessWidget {
  const OpportunityDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: AppSpacing.appBarHeight,
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          ),
          Icon(Icons.terminal, color: colorScheme.primary, size: AppSpacing.lg),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Ciara OS',
            style: AppTypography.monospace.copyWith(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
