import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/review/review_card.dart';
import 'package:flutter/material.dart';

class NextActionItem {
  const NextActionItem({
    required this.text,
    required this.checked,
    this.domain,
  });

  final String text;
  final bool checked;
  final Domain? domain;

  NextActionItem copyWith({String? text, bool? checked, Domain? domain}) {
    return NextActionItem(
      text: text ?? this.text,
      checked: checked ?? this.checked,
      domain: domain ?? this.domain,
    );
  }
}

class NextActionsChecklist extends StatelessWidget {
  const NextActionsChecklist({
    super.key,
    required this.items,
    required this.newActionController,
    required this.onToggle,
    required this.onAdd,
  });

  final List<NextActionItem> items;
  final TextEditingController newActionController;
  final void Function(int index) onToggle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Week Priorities',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.executionGap),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onToggle(i),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        _PriorityCheckbox(checked: items[i].checked),
                        const SizedBox(width: AppSpacing.sm),
                        if (items[i].domain != null)
                          Container(
                            width: 3,
                            height: AppSpacing.lg,
                            decoration: BoxDecoration(
                              color: context.domainColor(items[i].domain!),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                          ),
                        if (items[i].domain != null)
                          const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            items[i].text,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 14,
                              decoration: items[i].checked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: newActionController,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add action item...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Material(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.add,
                      size: AppSpacing.md,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityCheckbox extends StatelessWidget {
  const _PriorityCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: checked ? colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: checked ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: checked
          ? Icon(Icons.check, size: 12, color: colorScheme.onPrimary)
          : null,
    );
  }
}
