import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/widgets/today/builder_mode_card.dart';
import 'package:ciaraos/widgets/today/deep_focus_bar.dart';
import 'package:ciaraos/widgets/today/performance_snapshot_card.dart';
import 'package:flutter/material.dart';

class TodaySidebar extends StatelessWidget {
  const TodaySidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DeepFocusBar(),
        SizedBox(height: AppSpacing.lg),
        PerformanceSnapshotCard(),
        SizedBox(height: AppSpacing.lg),
        BuilderModeCard(),
      ],
    );
  }
}
