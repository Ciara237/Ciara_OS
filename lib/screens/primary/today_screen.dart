import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/widgets/today/today_action_row.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:ciaraos/widgets/today/today_screen_label.dart';
import 'package:ciaraos/widgets/today/today_sidebar.dart';
import 'package:ciaraos/widgets/today/today_task_list_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _todayWideBreakpoint = 1024.0;

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= _todayWideBreakpoint;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          const TodayHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.reviewPadding,
                AppSpacing.lg,
                AppSpacing.reviewPadding,
                AppSpacing.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.containerMax,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TodayScreenLabel(),
                      const SizedBox(height: AppSpacing.lg),
                      const TodayActionRow(),
                      const SizedBox(height: AppSpacing.lg),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Expanded(
                              flex: 8,
                              child: TodayTaskListSection(),
                            ),
                            SizedBox(width: AppSpacing.lg),
                            Expanded(
                              flex: 4,
                              child: TodaySidebar(),
                            ),
                          ],
                        )
                      else ...[
                        const TodayTaskListSection(),
                        const SizedBox(height: AppSpacing.lg),
                        const TodaySidebar(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
