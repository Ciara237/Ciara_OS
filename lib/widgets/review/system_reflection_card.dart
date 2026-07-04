import 'package:ciaraos/models/reflection_bullet.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/review/review_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SystemReflectionCard extends StatelessWidget {
  const SystemReflectionCard({
    super.key,
    required this.bullets,
    required this.weekMonday,
  });

  final List<ReflectionBullet> bullets;
  final DateTime weekMonday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekEnd = weekMonday.add(const Duration(days: 6));
    final logEnd = DateFormat('MM-dd-yyyy').format(weekEnd);

    return ReviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'SYSTEM REFLECTION',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.4,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < bullets.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _BulletLine(bullet: bullets[i]),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                '[LOG_END:$logEnd]',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                  fontSize: 9,
                  fontFamily: 'monospace',
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.bullet});

  final ReflectionBullet bullet;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, right: AppSpacing.sm),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
                height: 1.55,
                fontSize: 14,
              ),
              children: [
                for (final segment in bullet.segments)
                  TextSpan(
                    text: segment.text,
                    style: TextStyle(
                      fontWeight:
                          segment.bold ? FontWeight.w700 : FontWeight.w400,
                      fontStyle:
                          segment.italic ? FontStyle.italic : FontStyle.normal,
                      color: segment.bold
                          ? colorScheme.onSurface
                          : colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
