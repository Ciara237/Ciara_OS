import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> showTaskQuickActionsSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Task task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final repository = ref.read(taskRepositoryProvider);

      Future<void> updateTask(Task updated) {
        return repository.update(updated.toCompanion());
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.today, color: colorScheme.primary),
              title: Text(
                'Mark Today',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              onTap: () async {
                await updateTask(
                  task.copyWith(today: true, updatedAt: DateTime.now()),
                );
                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: colorScheme.primary),
              title: Text(
                'Mark Done',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              onTap: () async {
                await updateTask(
                  task.copyWith(
                    status: TaskStatus.done,
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
                context.push('/tasks/${task.id}');
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
                        'Delete task?',
                        style: AppTypography.headingMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      content: Text(
                        'This will permanently remove "${task.title}".',
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
                  await repository.delete(task.id);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
