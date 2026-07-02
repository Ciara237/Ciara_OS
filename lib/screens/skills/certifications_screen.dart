import 'package:ciaraos/models/certification.dart';
import 'package:ciaraos/providers/certification_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:ciaraos/widgets/skills/certification_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CertificationsScreen extends ConsumerWidget {
  const CertificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SidebarScreenScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          const _ScreenIntro(),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => showCertificationBottomSheet(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5),
              ),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'ADD CERTIFICATION',
              style: AppTypography.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _CertificationSection(
            status: CertificationStatus.earned,
            icon: Icons.verified_outlined,
            iconColor: const Color(0xFF34D399),
          ),
          const SizedBox(height: AppSpacing.xl),
          _CertificationSection(
            status: CertificationStatus.inProgress,
            icon: Icons.pending_outlined,
            iconColor: const Color(0xFFFBBF24),
          ),
          const SizedBox(height: AppSpacing.xl),
          _CertificationSection(
            status: CertificationStatus.planned,
            icon: Icons.event_note_outlined,
            iconColor: const Color(0xFF8E9197),
          ),
        ],
      ),
    );
  }
}

class _ScreenIntro extends StatelessWidget {
  const _ScreenIntro();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS · CERTIFICATIONS',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Certifications',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Track earned and in-progress professional certifications across engineering, security, and systems domains.',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CertificationSection extends ConsumerWidget {
  const _CertificationSection({
    required this.status,
    required this.icon,
    required this.iconColor,
  });

  final CertificationStatus status;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(certificationsByStatusProvider(status));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              certificationStatusLabel(status),
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        certsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Text(
            'Could not load certifications.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          data: (certs) {
            if (certs.isEmpty) {
              return Text(
                'No ${certificationStatusLabel(status).toLowerCase()} certifications yet.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            }

            return Column(
              children: certs
                  .map(
                    (cert) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CertificationCard(certification: cert),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CertificationCard extends ConsumerWidget {
  const _CertificationCard({required this.certification});

  final Certification certification;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete certification?'),
        content: Text(
          'Remove "${certification.name}" from your list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(certificationRepositoryProvider)
          .delete(certification.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = certificationStatusColor(certification.status);
    final domainColor = AppColors.domainColors[certification.domain]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showCertificationBottomSheet(
          context,
          certification: certification,
        ),
        onLongPress: () => _confirmDelete(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: AppSpacing.taskBorderWidth,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.radiusMd),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                      right: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: _CardBody(
                    certification: certification,
                    domainColor: domainColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.certification,
    required this.domainColor,
  });

  final Certification certification;
  final Color domainColor;

  @override
  Widget build(BuildContext context) {
    return switch (certification.status) {
      CertificationStatus.earned => _EarnedCardBody(
          certification: certification,
          domainColor: domainColor,
        ),
      CertificationStatus.inProgress => _InProgressCardBody(
          certification: certification,
          domainColor: domainColor,
        ),
      CertificationStatus.planned => _PlannedCardBody(
          certification: certification,
          domainColor: domainColor,
        ),
    };
  }
}

class _EarnedCardBody extends StatelessWidget {
  const _EarnedCardBody({
    required this.certification,
    required this.domainColor,
  });

  final Certification certification;
  final Color domainColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final issued = certification.dateEarned == null
        ? null
        : DateFormat('MMM yyyy').format(certification.dateEarned!).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _DomainChip(
              label: domainShortLabel(certification.domain),
              color: domainColor,
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: certificationStatusColor(CertificationStatus.earned),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'VERIFIED',
                  style: AppTypography.labelSmall.copyWith(
                    color: certificationStatusColor(CertificationStatus.earned),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          certification.name,
          style: AppTypography.headingMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          certification.issuer,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (issued != null || certification.externalLink != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (issued != null)
                Text(
                  'ISSUED: $issued',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              const Spacer(),
              if (certification.externalLink != null)
                TextButton(
                  onPressed: () => openCertificationLink(
                    context,
                    certification.externalLink,
                  ),
                  child: Text(
                    'VIEW CREDENTIAL',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InProgressCardBody extends StatelessWidget {
  const _InProgressCardBody({
    required this.certification,
    required this.domainColor,
  });

  final Certification certification;
  final Color domainColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fraction = certification.progressFraction ?? 0;
    final percent = (fraction * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                certification.name,
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            _DomainChip(
              label: domainShortLabel(certification.domain),
              color: domainColor,
            ),
          ],
        ),
        if (certification.targetDate != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Target: ${DateFormat.yMMMd().format(certification.targetDate!)}',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (certification.progressTotal > 0) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${certification.progressCurrent}/${certification.progressTotal} MODULES',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$percent%',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: certificationStatusColor(CertificationStatus.inProgress),
            ),
          ),
        ],
      ],
    );
  }
}

class _PlannedCardBody extends StatelessWidget {
  const _PlannedCardBody({
    required this.certification,
    required this.domainColor,
  });

  final Certification certification;
  final Color domainColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                certification.name,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${certification.issuer} · ${domainLabel(certification.domain)}',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              if (certification.targetDate != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Target: ${DateFormat.yMMMd().format(certification.targetDate!)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (certification.priority != null)
          _PriorityBadge(priority: certification.priority!),
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final CertificationPriority priority;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (priority) {
      CertificationPriority.low => AppColors.priorityLow,
      CertificationPriority.medium => AppColors.priorityMedium,
      CertificationPriority.high => AppColors.priorityHigh,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: priority == CertificationPriority.high
              ? colorScheme.error
              : color,
          fontSize: 9,
        ),
      ),
    );
  }
}
