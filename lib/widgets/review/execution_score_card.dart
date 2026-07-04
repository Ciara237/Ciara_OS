import 'package:ciaraos/models/weekly_debrief.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/widgets/review/review_card.dart';
import 'package:flutter/material.dart';

const _ringColor = Color(0xFF38BDF8);

class ExecutionScoreCard extends StatelessWidget {
  const ExecutionScoreCard({
    super.key,
    required this.debrief,
    required this.weekMonday,
  });

  final WeeklyDebrief debrief;
  final DateTime weekMonday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = debrief.executionScore.round();
    final progress = (debrief.executionScore / 100).clamp(0.0, 1.0);
    final systemId = _systemAuthId(weekMonday);

    return ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'SYSTEM_AUTH: $systemId',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                fontSize: 9,
                letterSpacing: 0.6,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor:
                            colorScheme.outlineVariant.withValues(alpha: 0.25),
                        color: _ringColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$score%',
                      style: AppTypography.headingLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Execution Score',
                      style: AppTypography.headingMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      debrief.scoreDescription,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _systemAuthId(DateTime weekMonday) {
    final value =
        (isoWeekNumber(weekMonday) * 34 + weekMonday.year % 1000) & 0xfff;
    return '0x${value.toRadixString(16).padLeft(3, '0').toUpperCase()}';
  }
}
