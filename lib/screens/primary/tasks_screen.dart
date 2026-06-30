import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/widgets/tasks/tasks_backlog_list_section.dart';
import 'package:ciaraos/widgets/tasks/tasks_filter_bar.dart';
import 'package:ciaraos/widgets/tasks/tasks_quick_add_bar.dart';
import 'package:ciaraos/widgets/tasks/tasks_screen_label.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          const TodayHeader(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    children: const [
                      TasksScreenLabel(),
                      SizedBox(height: AppSpacing.lg),
                      TasksFilterBar(),
                      SizedBox(height: AppSpacing.lg),
                      TasksBacklogListSection(),
                    ],
                  ),
                ),
                const TasksQuickAddBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
