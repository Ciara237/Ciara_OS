import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:flutter/material.dart';

class OpportunityMetadataSection extends StatelessWidget {
  const OpportunityMetadataSection({
    super.key,
    required this.updatedAt,
    required this.leadQuality,
    required this.onLeadQualityChanged,
  });

  final DateTime updatedAt;
  final int? leadQuality;
  final ValueChanged<int> onLeadQualityChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetadataRow(
          label: 'Last Modified',
          value: relativeTimeLabel(updatedAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text(
              'Lead Quality',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            for (var rating = 1; rating <= 3; rating++)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.xl,
                  minHeight: AppSpacing.xl,
                ),
                onPressed: () => onLeadQualityChanged(rating),
                icon: Icon(
                  rating <= (leadQuality ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: rating <= (leadQuality ?? 0)
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: AppSpacing.lg,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
