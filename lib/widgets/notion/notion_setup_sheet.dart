import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

Future<void> showNotionSetupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connect Notion',
                style: AppTypography.headingLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SetupStep(
                number: '1',
                text:
                    'Create a Notion integration at notion.so/my-integrations',
              ),
              const _SetupStep(
                number: '2',
                text: 'Share your database with the integration',
              ),
              const _SetupStep(
                number: '3',
                text: 'Add NOTION_TOKEN=... to backend .env',
              ),
              const _SetupStep(
                number: '4',
                text: 'Add NOTION_DATABASE_ID=... to backend .env',
              ),
              const _SetupStep(
                number: '5',
                text: 'Restart the backend',
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'NOTION_TOKEN=your_notion_integration_token\n'
                  'NOTION_DATABASE_ID=your_database_id',
                  style: AppTypography.labelSmall.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
