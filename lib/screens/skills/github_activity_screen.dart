import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/providers/github_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubActivityScreen extends ConsumerStatefulWidget {
  const GitHubActivityScreen({super.key});

  @override
  ConsumerState<GitHubActivityScreen> createState() =>
      _GitHubActivityScreenState();
}

class _GitHubActivityScreenState extends ConsumerState<GitHubActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoSync());
  }

  Future<void> _maybeAutoSync() async {
    final notifier = ref.read(githubActivityProvider.notifier);
    if (notifier.shouldAutoSync) {
      await notifier.sync();
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(githubActivityProvider);
    final notifier = ref.read(githubActivityProvider.notifier);
    final isSyncing = activityAsync.isLoading;

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
          _SyncRow(
            isSyncing: isSyncing,
            onSync: notifier.sync,
          ),
          const SizedBox(height: AppSpacing.lg),
          activityAsync.when(
            loading: () => const _LoadingBody(),
            error: (_, _) => const _ErrorBody(),
            data: (activity) {
              if (activity == null) {
                return const _EmptyBody();
              }
              return _ActivityBody(
                activity: activity,
                onOpenUrl: _openUrl,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScreenIntro extends ConsumerWidget {
  const _ScreenIntro();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final activity = ref.watch(githubActivityProvider).value;
    final syncedLabel = activity == null
        ? 'Never synced'
        : 'Last synced: ${relativeTimeLabel(activity.syncedAt.toLocal())}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS · ENGINEERING',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'GitHub Activity',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          syncedLabel,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({
    required this.isSyncing,
    required this.onSync,
  });

  final bool isSyncing;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: isSyncing ? null : onSync,
      icon: isSyncing
          ? SizedBox(
              width: AppSpacing.md,
              height: AppSpacing.md,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            )
          : const Icon(Icons.refresh, size: 18),
      label: Text(
        isSyncing ? 'Syncing…' : '↻ Sync Now',
        style: AppTypography.labelLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        side: BorderSide(color: colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Text(
        'No GitHub data yet. Sync to pull your public activity.',
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Text(
        'Could not reach the GitHub activity backend. Check that the server is running.',
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: colorScheme.error,
        ),
      ),
    );
  }
}

class _ActivityBody extends StatelessWidget {
  const _ActivityBody({
    required this.activity,
    required this.onOpenUrl,
  });

  final GitHubActivity activity;
  final Future<void> Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final sortedRepos = [...activity.repos]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileCard(activity: activity),
        const SizedBox(height: AppSpacing.lg),
        _LanguagesCard(languages: activity.languages),
        const SizedBox(height: AppSpacing.lg),
        _RecentCommitsSection(
          commits: activity.recentCommits.take(10).toList(),
          onOpenUrl: onOpenUrl,
        ),
        const SizedBox(height: AppSpacing.lg),
        _RepositoriesSection(
          repos: sortedRepos,
          onOpenUrl: onOpenUrl,
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.activity});

  final GitHubActivity activity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: activity.avatarUrl.isNotEmpty
                    ? NetworkImage(activity.avatarUrl)
                    : null,
                child: activity.avatarUrl.isEmpty
                    ? Text(
                        activity.username.isNotEmpty
                            ? activity.username[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                activity.username,
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatCell(label: 'Repos', value: '${activity.publicRepos}'),
              _StatCell(label: 'Followers', value: '${activity.followers}'),
              _StatCell(label: 'Following', value: '${activity.following}'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatCell(
                label: 'This week',
                value: '${activity.totalCommitsThisWeek} commits',
              ),
              _StatCell(
                label: 'Streak',
                value: '${activity.contributionStreak} days',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagesCard extends StatelessWidget {
  const _LanguagesCard({required this.languages});

  final Map<String, int> languages;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = languages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LANGUAGES',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (entries.isEmpty)
            Text(
              'No language data available.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _LanguageBar(
                  language: entry.key,
                  percentage: entry.value,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageBar extends StatelessWidget {
  const _LanguageBar({
    required this.language,
    required this.percentage,
  });

  final String language;
  final int percentage;

  Color _colorForLanguage(ColorScheme colorScheme) {
    switch (language) {
      case 'Dart':
        return AppColors.domainColors[Domain.engineering]!;
      case 'Python':
        return AppColors.domainColors[Domain.builder]!;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final barColor = _colorForLanguage(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '$percentage%',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainer,
            color: barColor,
          ),
        ),
      ],
    );
  }
}

class _RecentCommitsSection extends StatelessWidget {
  const _RecentCommitsSection({
    required this.commits,
    required this.onOpenUrl,
  });

  final List<GitHubCommit> commits;
  final Future<void> Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT COMMITS',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (commits.isEmpty)
          Text(
            'No recent commits found.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...commits.map(
            (commit) => _CommitTile(
              commit: commit,
              onTap: () => onOpenUrl(commit.url),
            ),
          ),
      ],
    );
  }
}

class _CommitTile extends StatelessWidget {
  const _CommitTile({
    required this.commit,
    required this.onTap,
  });

  final GitHubCommit commit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.domainColors[Domain.engineering]!
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  commit.repo,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.domainColors[Domain.engineering],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commit.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      relativeTimeLabel(commit.date.toLocal()),
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepositoriesSection extends StatelessWidget {
  const _RepositoriesSection({
    required this.repos,
    required this.onOpenUrl,
  });

  final List<GitHubRepo> repos;
  final Future<void> Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REPOSITORIES',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (repos.isEmpty)
          Text(
            'No repositories found.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...repos.map(
            (repo) => _RepoCard(
              repo: repo,
              onTap: () => onOpenUrl(repo.htmlUrl),
            ),
          ),
      ],
    );
  }
}

class _RepoCard extends StatelessWidget {
  const _RepoCard({
    required this.repo,
    required this.onTap,
  });

  final GitHubRepo repo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final updatedLabel =
        DateFormat('MMM d, yyyy').format(repo.updatedAt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        repo.name,
                        style: AppTypography.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    if (repo.language != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          repo.language!,
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                if (repo.description != null && repo.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    repo.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.star_outline, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${repo.stars}',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.call_split, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${repo.forks}',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      updatedLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
