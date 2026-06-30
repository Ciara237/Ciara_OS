import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/widgets/today/deep_focus_timer.dart';
import 'package:ciaraos/widgets/today/productivity_index_card.dart';
import 'package:ciaraos/widgets/today/today_action_row.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:ciaraos/widgets/today/today_screen_label.dart';
import 'package:ciaraos/widgets/today/today_task_list_section.dart';
import 'package:ciaraos/widgets/today/upcoming_milestone_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          const TodayHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  TodayScreenLabel(),
                  SizedBox(height: AppSpacing.lg),
                  TodayActionRow(),
                  SizedBox(height: AppSpacing.lg),
                  ProductivityIndexCard(),
                  SizedBox(height: AppSpacing.md),
                  UpcomingMilestoneCard(),
                  SizedBox(height: AppSpacing.xl),
                  TodayTaskListSection(),
                  SizedBox(height: AppSpacing.lg),
                  DeepFocusTimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
