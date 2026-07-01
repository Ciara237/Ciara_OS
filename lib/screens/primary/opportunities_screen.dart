import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/common/empty_state.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_card.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_group_header.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_quick_actions_sheet.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  ConsumerState<OpportunitiesScreen> createState() =>
      _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends ConsumerState<OpportunitiesScreen> {
  final Set<OpportunityStatus> _expandedGroups = {
    for (final status in OpportunityStatus.values)
      if (status != OpportunityStatus.rejected &&
          status != OpportunityStatus.closed)
        status,
  };

  bool _isGroupExpanded(OpportunityStatus status) {
    if (status != OpportunityStatus.rejected &&
        status != OpportunityStatus.closed) {
      return true;
    }
    return _expandedGroups.contains(status);
  }

  void _toggleGroup(OpportunityStatus status) {
    setState(() {
      if (_expandedGroups.contains(status)) {
        _expandedGroups.remove(status);
      } else {
        _expandedGroups.add(status);
      }
    });
  }

  void _openNewOpportunity() {
    context.push('/opportunities/new');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupedOpportunities = ref.watch(groupedOpportunitiesProvider);
    final activeCount = ref.watch(activeOpportunitiesCountProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewOpportunity,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: ColoredBox(
        color: colorScheme.surface,
        child: Column(
          children: [
            const TodayHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl + AppSpacing.xl,
                ),
                children: [
                  _OpportunitiesScreenLabel(
                    activeCount: activeCount,
                    stageCount: groupedOpportunities.value?.length ?? 0,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  groupedOpportunities.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => EmptyState(
                      message: 'Could not load opportunities.',
                      actionLabel: 'RETRY',
                      onAction: () => ref.invalidate(allOpportunitiesProvider),
                    ),
                    data: (groups) {
                      if (groups.isEmpty) {
                        return EmptyState(
                          message:
                              'No opportunities tracked yet. Add your first application to get started.',
                          actionLabel: 'ADD OPPORTUNITY',
                          onAction: _openNewOpportunity,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final status in OpportunityStatus.values)
                            if (groups.containsKey(status)) ...[
                              OpportunityGroupHeader(
                                status: status,
                                count: groups[status]!.length,
                                isExpanded: _isGroupExpanded(status),
                                isCollapsible: status ==
                                        OpportunityStatus.rejected ||
                                    status == OpportunityStatus.closed,
                                onToggle: () => _toggleGroup(status),
                              ),
                              if (_isGroupExpanded(status))
                                Column(
                                  children: [
                                    for (var i = 0;
                                        i < groups[status]!.length;
                                        i++) ...[
                                      if (i > 0)
                                        const SizedBox(height: AppSpacing.md),
                                      OpportunityCard(
                                        opportunity: groups[status]![i],
                                        onTap: () => context.push(
                                          '/opportunities/${groups[status]![i].id}',
                                        ),
                                        onLongPress: () =>
                                            showOpportunityQuickActionsSheet(
                                          context: context,
                                          ref: ref,
                                          opportunity: groups[status]![i],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunitiesScreenLabel extends StatelessWidget {
  const _OpportunitiesScreenLabel({
    required this.activeCount,
    required this.stageCount,
  });

  final AsyncValue<int> activeCount;
  final int stageCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = activeCount.value ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Pipeline',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tracking $count active opportunities across $stageCount stages.',
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
