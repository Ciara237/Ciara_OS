import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _activePipelineOrder = [
  OpportunityStatus.researching,
  OpportunityStatus.applying,
  OpportunityStatus.submitted,
  OpportunityStatus.interviewing,
  OpportunityStatus.offer,
];

OpportunityStatus? nextOpportunityStatus(OpportunityStatus status) {
  final index = _activePipelineOrder.indexOf(status);
  if (index == -1 || index >= _activePipelineOrder.length - 1) {
    return null;
  }
  return _activePipelineOrder[index + 1];
}

Future<void> showOpportunityQuickActionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Opportunity opportunity,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final repository = ref.read(opportunityRepositoryProvider);
      final nextStatus = nextOpportunityStatus(opportunity.status);

      Future<void> updateOpportunity(Opportunity updated) {
        return repository.update(updated.toCompanion());
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (nextStatus != null)
              ListTile(
                leading: Icon(Icons.arrow_forward, color: colorScheme.primary),
                title: Text(
                  'Move to Next Stage',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () async {
                  await updateOpportunity(
                    opportunity.copyWith(
                      status: nextStatus,
                      updatedAt: DateTime.now(),
                    ),
                  );
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ListTile(
              leading: Icon(Icons.edit, color: colorScheme.primary),
              title: Text(
                'Edit',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/opportunities/${opportunity.id}');
              },
            ),
            ListTile(
              leading: Icon(Icons.archive, color: colorScheme.primary),
              title: Text(
                'Archive',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              onTap: () async {
                await updateOpportunity(
                  opportunity.copyWith(
                    status: OpportunityStatus.closed,
                    updatedAt: DateTime.now(),
                  ),
                );
                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: colorScheme.error),
              title: Text(
                'Delete',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: Text(
                        'Delete opportunity?',
                        style: AppTypography.headingMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      content: Text(
                        'This will permanently remove "${opportunity.title}".',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  await repository.delete(opportunity.id);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
