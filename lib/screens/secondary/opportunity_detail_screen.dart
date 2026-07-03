import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/link_utils.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:ciaraos/widgets/navigation/minimal_back_header.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_documents_card.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_fit_notes_card.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_metadata_section.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_pipeline_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class OpportunityDetailScreen extends ConsumerStatefulWidget {
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  ConsumerState<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends ConsumerState<OpportunityDetailScreen> {
  bool _isEditingFitNotes = false;
  late final TextEditingController _fitNotesController;

  int get _id => int.parse(widget.opportunityId);

  @override
  void initState() {
    super.initState();
    _fitNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _fitNotesController.dispose();
    super.dispose();
  }

  Future<void> _persistOpportunity(Opportunity opportunity) async {
    await ref.read(opportunityRepositoryProvider).update(
          opportunity
              .copyWith(updatedAt: DateTime.now())
              .toCompanion(),
        );
    ref.invalidate(opportunityByIdProvider(_id));
  }

  Future<void> _toggleDocument(
    Opportunity opportunity,
    int index,
  ) async {
    final documents = [...opportunity.documents];
    final current = documents[index];
    documents[index] = current.copyWith(completed: !current.completed);
    final ready = documents.where((doc) => doc.completed).length;

    await _persistOpportunity(
      opportunity.copyWith(
        documents: documents,
        documentsReady: ready,
      ),
    );
  }

  Future<void> _saveFitNotes(Opportunity opportunity) async {
    final text = _fitNotesController.text.trim();
    await _persistOpportunity(
      opportunity.copyWith(
        fitNotes: text.isEmpty ? null : text,
        clearFitNotes: text.isEmpty,
      ),
    );
    setState(() => _isEditingFitNotes = false);
  }

  Future<void> _updateLeadQuality(Opportunity opportunity, int rating) async {
    await _persistOpportunity(
      opportunity.copyWith(leadQuality: rating),
    );
  }

  Future<void> _moveToNextStage(Opportunity opportunity) async {
    final nextStatus = nextOpportunityStatus(opportunity.status);
    if (nextStatus == null) {
      return;
    }

    await _persistOpportunity(
      opportunity.copyWith(status: nextStatus),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moved to ${opportunityStatusStepLabel(nextStatus)}.',
        ),
      ),
    );
  }

  Future<void> _deleteOpportunity(Opportunity opportunity) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete opportunity?',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This will permanently remove "${opportunity.title}".',
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

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(opportunityRepositoryProvider).delete(opportunity.id);
    if (!mounted) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final opportunityAsync = ref.watch(opportunityByIdProvider(_id));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const MinimalBackHeader(),
          Expanded(
            child: opportunityAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Could not load opportunity.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (opportunity) {
                if (opportunity == null) {
                  return Center(
                    child: Text(
                      'Opportunity not found.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                if (!_isEditingFitNotes &&
                    _fitNotesController.text.isEmpty &&
                    opportunity.fitNotes != null) {
                  _fitNotesController.text = opportunity.fitNotes!;
                }

                final statusColor = opportunityStatusColor(opportunity.status);
                final deadline = deadlineDisplayFor(opportunity.deadline);
                final showNextStage = nextOpportunityStatus(
                      opportunity.status,
                    ) !=
                    null;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  children: [
                    _OpportunityTopSection(
                      opportunity: opportunity,
                      statusColor: statusColor,
                      deadline: deadline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OpportunityPipelineStepper(
                      currentStatus: opportunity.status,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OpportunityDocumentsCard(
                      opportunity: opportunity,
                      onToggleDocument: (index) =>
                          _toggleDocument(opportunity, index),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OpportunityFitNotesCard(
                      isEditing: _isEditingFitNotes,
                      fitNotes: opportunity.fitNotes,
                      controller: _fitNotesController,
                      onEdit: () => setState(() => _isEditingFitNotes = true),
                      onSave: () => _saveFitNotes(opportunity),
                    ),
                    if (opportunity.link != null &&
                        opportunity.link!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _OpportunityApplicationLinkCard(
                        link: opportunity.link!.trim(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    OpportunityMetadataSection(
                      updatedAt: opportunity.updatedAt,
                      leadQuality: opportunity.leadQuality,
                      onLeadQualityChanged: (rating) =>
                          _updateLeadQuality(opportunity, rating),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (showNextStage) ...[
                      FilledButton(
                        onPressed: () => _moveToNextStage(opportunity),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: Text(
                          'MOVE TO NEXT STAGE →',
                          style: AppTypography.labelLarge.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    OutlinedButton(
                      onPressed: () =>
                          context.push('/opportunities/${opportunity.id}/edit'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: const Text('EDIT FULL DETAILS'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () => _deleteOpportunity(opportunity),
                        child: Text(
                          'DELETE',
                          style: AppTypography.labelLarge.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityTopSection extends StatelessWidget {
  const _OpportunityTopSection({
    required this.opportunity,
    required this.statusColor,
    required this.deadline,
  });

  final Opportunity opportunity;
  final Color statusColor;
  final OpportunityDeadlineDisplay deadline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUrgent = deadline.urgency == OpportunityDeadlineUrgency.urgent ||
        deadline.urgency == OpportunityDeadlineUrgency.dueToday ||
        deadline.urgency == OpportunityDeadlineUrgency.overdue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                opportunityTypeTagLabel(opportunity.type),
                style: AppTypography.labelSmall.copyWith(color: statusColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (isUrgent) ...[
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    deadline.overline!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    deadline.headline!,
                    style: AppTypography.headingLarge.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ] else if (deadline.quietDate != null) ...[
              const Spacer(),
              Text(
                deadline.quietDate!,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          opportunity.title,
          style: AppTypography.displayLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          opportunity.organization,
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: AppSpacing.lg,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                opportunity.location,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OpportunityApplicationLinkCard extends StatelessWidget {
  const _OpportunityApplicationLinkCard({required this.link});

  final String link;

  Future<void> _openLink() async {
    final normalized = LinkUtils.normalizeLink(link);
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openLink,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LinkUtils.linkLabel(link),
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      LinkUtils.linkIcon(link),
                      size: AppSpacing.lg,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        LinkUtils.displayLink(link),
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
