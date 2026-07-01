import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_card.dart';
import 'package:flutter/material.dart';

class OpportunityGroupHeader extends StatelessWidget {
  const OpportunityGroupHeader({
    super.key,
    required this.status,
    required this.count,
    required this.isExpanded,
    required this.isCollapsible,
    this.onToggle,
  });

  final OpportunityStatus status;
  final int count;
  final bool isExpanded;
  final bool isCollapsible;
  final VoidCallback? onToggle;

  static String _statusLabel(OpportunityStatus status) {
    return switch (status) {
      OpportunityStatus.researching => 'RESEARCHING',
      OpportunityStatus.applying => 'APPLYING',
      OpportunityStatus.submitted => 'SUBMITTED',
      OpportunityStatus.interviewing => 'INTERVIEWING',
      OpportunityStatus.offer => 'OFFER',
      OpportunityStatus.rejected => 'REJECTED',
      OpportunityStatus.closed => 'CLOSED',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = opportunityStatusColor(status);

    return InkWell(
      onTap: isCollapsible ? onToggle : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${_statusLabel(status)} ($count)',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (isCollapsible)
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: colorScheme.onSurfaceVariant,
                size: AppSpacing.lg,
              ),
          ],
        ),
      ),
    );
  }
}
