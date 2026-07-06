import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

const dailyBriefSessionAmber = Color(0xFFFFB02E);
const dailyBriefWideBreakpoint = 900.0;

/// Stitch top bar — terminal + Ciara OS, optional trailing actions.
class DailyBriefChrome extends StatelessWidget {
  const DailyBriefChrome({
    super.key,
    this.showSearch = true,
    this.showProfile = false,
    this.clockLabel,
  });

  final bool showSearch;
  final bool showProfile;
  final String? clockLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.terminal, size: 20, color: colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Ciara OS',
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (clockLabel != null)
              Text(
                clockLabel!,
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            if (showSearch) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.search,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
            if (showProfile) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.person_outline,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}