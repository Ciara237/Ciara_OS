import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:flutter/material.dart';

class OpportunityDocumentsCard extends StatelessWidget {
  const OpportunityDocumentsCard({
    super.key,
    required this.opportunity,
    required this.onToggleDocument,
  });

  final Opportunity opportunity;
  final void Function(int index) onToggleDocument;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = opportunityStatusColor(opportunity.status);
    final total = opportunity.documentsTotal;
    final ready = opportunity.documentsReady;

    final Color countColor;
    if (total > 0 && ready == total) {
      countColor = opportunityDocsCompleteColor;
    } else if (ready > 0) {
      countColor = opportunityDocsPartialColor;
    } else {
      countColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'DOCUMENTS CHECKLIST',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (total > 0)
                Text(
                  '$ready/$total COMPLETE',
                  style: AppTypography.labelSmall.copyWith(color: countColor),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (opportunity.documents.isEmpty)
            Text(
              'No documents listed.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (var i = 0; i < opportunity.documents.length; i++)
              _DocumentRow(
                document: opportunity.documents[i],
                statusColor: statusColor,
                onChanged: () => onToggleDocument(i),
              ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.document,
    required this.statusColor,
    required this.onChanged,
  });

  final OpportunityDocument document;
  final Color statusColor;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Checkbox(
                value: document.completed,
                onChanged: (_) => onChanged(),
                activeColor: statusColor,
                checkColor: colorScheme.onPrimary,
                side: BorderSide(color: colorScheme.onSurfaceVariant),
              ),
              Expanded(
                child: Text(
                  document.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: document.completed
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    decoration: document.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
