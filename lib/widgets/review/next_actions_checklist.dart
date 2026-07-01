import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class NextActionItem {
  const NextActionItem({
    required this.text,
    required this.checked,
  });

  final String text;
  final bool checked;

  NextActionItem copyWith({String? text, bool? checked}) {
    return NextActionItem(
      text: text ?? this.text,
      checked: checked ?? this.checked,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Actions',
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < items.length; i++)
          CheckboxListTile(
            value: items[i].checked,
            onChanged: (_) => onToggle(i),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              items[i].text,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
                decoration: items[i].checked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newActionController,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Add action...',
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}
