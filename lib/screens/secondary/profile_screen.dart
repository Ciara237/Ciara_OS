import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/services/profile_preferences.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/widgets/navigation/primary_drawer.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _avatarSize = 64.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).reload();
    });
  }

  Future<void> _showEditProfileDialog(ProfileData profile) async {
    final nameController = TextEditingController(
      text: profile.resolvedDisplayName == 'Your Name'
          ? ''
          : profile.resolvedDisplayName,
    );
    final bioController = TextEditingController(text: profile.tagline);
    final githubController = TextEditingController(text: profile.githubUsername);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Text(
            'Edit Profile',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'USERNAME',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'BIO',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: bioController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Short tagline or bio',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'GITHUB USERNAME',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: githubController,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Ciara237',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                final github = normalizeGithubUsername(githubController.text);
                if (!isValidGithubUsername(github)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'GitHub username cannot contain spaces or @.',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true && mounted) {
      await ref
          .read(profileProvider.notifier)
          .saveDisplayName(nameController.text);
      await ref.read(profileProvider.notifier).saveTagline(bioController.text);
      await ref
          .read(profileProvider.notifier)
          .saveGithubUsername(githubController.text);
    }

    nameController.dispose();
    bioController.dispose();
    githubController.dispose();
  }

  Future<void> _openGithub(String username) async {
    final uri = Uri.parse('https://github.com/$username');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final monday = mondayOfWeek(now);
    final tasksAsync = ref.watch(allTasksProvider);
    final projectsAsync = ref.watch(allProjectsProvider);
    final opportunitiesAsync = ref.watch(allOpportunitiesProvider);
    final weekCompletedAsync = ref.watch(weekCompletedTasksProvider(monday));
    final profile = ref.watch(profileProvider);

    return Scaffold(
      drawer: const PrimaryDrawer(),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const TodayHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: AppSpacing.containerMax),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    children: [
                      const _ProfileHeader(),
                const SizedBox(height: AppSpacing.reviewGap),
                _IdentitySection(
                  displayName: profile.resolvedDisplayName,
                  initials: profile.initials,
                  tagline: profile.tagline,
                  onEdit: () => _showEditProfileDialog(profile),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _QuickStatsRow(
                  tasksAsync: tasksAsync,
                  projectsAsync: projectsAsync,
                  opportunitiesAsync: opportunitiesAsync,
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                weekCompletedAsync.when(
                  loading: () => const _SectionCard(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const _ThisWeekCard(
                    completedCount: 0,
                  ),
                  data: (completedTasks) {
                    return _ThisWeekCard(
                      completedCount: completedTasks.length,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                tasksAsync.when(
                  loading: () => const _SectionCard(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const _DomainBreakdownSection(breakdown: []),
                  data: (tasks) => _DomainBreakdownSection(
                    breakdown: _domainBreakdown(tasks),
                  ),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _AboutSection(
                  githubUsername: profile.githubUsername,
                  onGithubTap: () => _openGithub(profile.githubUsername),
                ),
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

  List<_DomainStat> _domainBreakdown(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const [];
    }

    final counts = <Domain, int>{};
    for (final task in tasks) {
      counts[task.domain] = (counts[task.domain] ?? 0) + 1;
    }

    final total = tasks.length;
    final stats = counts.entries
        .map(
          (entry) => _DomainStat(
            domain: entry.key,
            count: entry.value,
            percentage: (entry.value / total) * 100,
          ),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return stats;
  }
}

class _DomainStat {
  const _DomainStat({
    required this.domain,
    required this.count,
    required this.percentage,
  });

  final Domain domain;
  final int count;
  final double percentage;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'PROFILE',
      style: AppTypography.monospace.copyWith(
        color: colorScheme.onSurface,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _IdentitySection extends StatelessWidget {
  const _IdentitySection({
    required this.displayName,
    required this.initials,
    required this.tagline,
    required this.onEdit,
  });

  final String displayName;
  final String initials;
  final String tagline;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: _ProfileScreenState._avatarSize / 2,
          backgroundColor: colorScheme.primary,
          child: Text(
            initials,
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayName,
                textAlign: TextAlign.center,
                style: AppTypography.headingLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: AppSpacing.md,
                color: colorScheme.onSurfaceVariant,
              ),
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              constraints: const BoxConstraints(),
              tooltip: 'Edit profile',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.tasksAsync,
    required this.projectsAsync,
    required this.opportunitiesAsync,
  });

  final AsyncValue<List<Task>> tasksAsync;
  final AsyncValue<List<Project>> projectsAsync;
  final AsyncValue<List<Opportunity>> opportunitiesAsync;

  @override
  Widget build(BuildContext context) {
    final taskCount = tasksAsync.maybeWhen(
      data: (tasks) => tasks.length,
      orElse: () => 0,
    );
    final activeProjects = projectsAsync.maybeWhen(
      data: (projects) =>
          projects.where((p) => p.status == ProjectStatus.active).length,
      orElse: () => 0,
    );
    final activeOpportunities = opportunitiesAsync.maybeWhen(
      data: (opportunities) => opportunities
          .where(
            (o) =>
                o.status != OpportunityStatus.rejected &&
                o.status != OpportunityStatus.closed,
          )
          .length,
      orElse: () => 0,
    );

    return Row(
      children: [
        Expanded(
          child: _StatCard(label: 'Total Tasks', value: '$taskCount'),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(label: 'Active Projects', value: '$activeProjects'),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            label: 'Opportunities',
            value: '$activeOpportunities',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.headingLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThisWeekCard extends StatelessWidget {
  const _ThisWeekCard({
    required this.completedCount,
  });

  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$completedCount',
            style: AppTypography.headingLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            completedCount == 1
                ? 'task completed'
                : 'tasks completed',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DomainBreakdownSection extends StatelessWidget {
  const _DomainBreakdownSection({required this.breakdown});

  final List<_DomainStat> breakdown;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOMAIN BREAKDOWN',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (breakdown.isEmpty)
            Text(
              'No tasks yet.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            for (final stat in breakdown) ...[
              _DomainRow(stat: stat),
              if (stat != breakdown.last) const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _DomainRow extends StatelessWidget {
  const _DomainRow({required this.stat});

  final _DomainStat stat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(stat.domain);

    return Row(
      children: [
        Container(
          width: 3,
          height: AppSpacing.lg,
          decoration: BoxDecoration(
            color: domainColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            domainLabel(stat.domain),
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '${stat.count}',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 40,
          child: Text(
            '${stat.percentage.round()}%',
            textAlign: TextAlign.right,
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.githubUsername,
    required this.onGithubTap,
  });

  final String githubUsername;
  final VoidCallback onGithubTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ciara OS',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'v1.0.0',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Built with Flutter',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: onGithubTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(
                'https://github.com/$githubUsername',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }
}
