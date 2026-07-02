import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class OpportunityFitNotesCard extends StatelessWidget {
  const OpportunityFitNotesCard({
    super.key,
    required this.isEditing,
    required this.fitNotes,
    required this.controller,
    required this.onEdit,
    required this.onSave,
  });

  final bool isEditing;
  final String? fitNotes;
  final TextEditingController controller;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasNotes = fitNotes != null && fitNotes!.trim().isNotEmpty;

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
                  'FIT NOTES',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: isEditing ? onSave : onEdit,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.xl,
                  minHeight: AppSpacing.xl,
                ),
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  size: AppSpacing.lg,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          if (isEditing)
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: null,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Add fit notes...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              hasNotes ? fitNotes! : 'No fit notes added.',
              style: AppTypography.bodyMedium.copyWith(
                color: hasNotes
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
