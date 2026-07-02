import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/providers/github_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/navigation/minimal_back_header.dart';
import 'package:ciaraos/widgets/skills/github_repo_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubRepositoriesScreen extends ConsumerWidget {
  const GitHubRepositoriesScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final activity = ref.watch(githubActivityProvider).value;
    final sortedRepos = [...?activity?.repos]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final remainingRepos = sortedRepos.length > 5
        ? sortedRepos.sublist(5)
        : <GitHubRepo>[];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const MinimalBackHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Text(
                  'REPOSITORIES',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (remainingRepos.isEmpty)
                  Text(
                    'No additional repositories.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...remainingRepos.map(
                    (repo) => GitHubRepoCard(
                      repo: repo,
                      onTap: () => _openUrl(repo.htmlUrl),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
