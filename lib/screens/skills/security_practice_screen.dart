import 'package:ciaraos/models/security_activity.dart';
import 'package:ciaraos/providers/security_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _securityRed = Color(0xFFEF4444);
const _htbSkillKeys = [
  'Web',
  'Network',
  'Crypto',
  'Forensics',
  'Reversing',
  'OSINT',
  'Pwn',
  'Misc',
];

class SecurityPracticeScreen extends ConsumerStatefulWidget {
  const SecurityPracticeScreen({super.key});

  @override
  ConsumerState<SecurityPracticeScreen> createState() =>
      _SecurityPracticeScreenState();
}

class _SecurityPracticeScreenState extends ConsumerState<SecurityPracticeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _htbAutoSynced = false;
  bool _h1AutoSynced = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoSyncTab(0));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }
    ref.read(activeSecurityTabProvider.notifier).state = _tabController.index;
    setState(() {});
    _maybeAutoSyncTab(_tabController.index);
  }

  Future<void> _maybeAutoSyncTab(int index) async {
    if (index == 0) {
      if (_htbAutoSynced) {
        return;
      }
      final notifier = ref.read(hackTheBoxProvider.notifier);
      if (notifier.shouldAutoSync) {
        _htbAutoSynced = true;
        await notifier.sync();
      }
      return;
    }

    if (_h1AutoSynced) {
      return;
    }
    final notifier = ref.read(hackerOneProvider.notifier);
    if (notifier.shouldAutoSync) {
      _h1AutoSynced = true;
      await notifier.sync();
    }
  }

  Future<void> _syncActiveTab() async {
    if (_tabController.index == 0) {
      await ref.read(hackTheBoxProvider.notifier).sync();
    } else {
      await ref.read(hackerOneProvider.notifier).sync();
    }
  }

  bool get _isSyncing {
    if (_tabController.index == 0) {
      return ref.watch(hackTheBoxProvider).isLoading;
    }
    return ref.watch(hackerOneProvider).isLoading;
  }

  Future<void> _showManualLogSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => _ManualLogSheet(
        onSubmit: (log) async {
          final ok =
              await ref.read(securityServiceProvider).logManualActivity(log);
          if (!context.mounted) {
            return;
          }
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok ? 'Activity logged.' : 'Could not log activity.',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SidebarScreenScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _ScreenIntro(isHtbTab: _tabController.index == 0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _SyncRow(
              isSyncing: _isSyncing,
              onSync: _syncActiveTab,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TabBar(
            controller: _tabController,
            labelColor: _securityRed,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: _securityRed,
            indicatorWeight: 2,
            labelStyle: AppTypography.labelLarge,
            unselectedLabelStyle: AppTypography.labelLarge,
            tabs: const [
              Tab(text: 'HackTheBox'),
              Tab(text: 'HackerOne'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HackTheBoxTab(onLogManual: _showManualLogSheet),
                _HackerOneTab(onLogManual: _showManualLogSheet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenIntro extends ConsumerWidget {
  const _ScreenIntro({required this.isHtbTab});

  final bool isHtbTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final htb = ref.watch(hackTheBoxProvider).value;
    final h1 = ref.watch(hackerOneProvider).value;
    final syncedAt = isHtbTab ? htb?.syncedAt : h1?.syncedAt;
    final syncedLabel = syncedAt == null
        ? 'Never synced'
        : 'Last synced: ${relativeTimeLabel(syncedAt.toLocal())}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS · SECURITY',
          style: AppTypography.labelSmall.copyWith(
            color: _securityRed,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Security Practice',
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
  const _SyncRow({required this.isSyncing, required this.onSync});

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
      ),
    );
  }
}

class _HackTheBoxTab extends ConsumerWidget {
  const _HackTheBoxTab({required this.onLogManual});

  final VoidCallback onLogManual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(hackTheBoxProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _ErrorMessage(
            message: 'Could not load HackTheBox data.',
          ),
          data: (profile) {
            if (profile == null) {
              return const _ErrorMessage(
                message: 'No HackTheBox data. Sync to pull your profile.',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HtbProfileCard(profile: profile),
                const SizedBox(height: AppSpacing.lg),
                _HtbSkillCoverageCard(coverage: profile.skillCoverage),
                const SizedBox(height: AppSpacing.lg),
                _HtbRecentActivitySection(activity: profile.recentActivity),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _ManualLogButton(onPressed: onLogManual),
      ],
    );
  }
}

class _HackerOneTab extends ConsumerWidget {
  const _HackerOneTab({required this.onLogManual});

  final VoidCallback onLogManual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(hackerOneProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const _ErrorMessage(
            message: 'Could not load HackerOne data.',
          ),
          data: (profile) {
            if (profile == null) {
              return const _ErrorMessage(
                message: 'No HackerOne data. Sync to pull your profile.',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _H1ProfileCard(profile: profile),
                const SizedBox(height: AppSpacing.lg),
                _H1BountyCard(summary: profile.bountySummary),
                const SizedBox(height: AppSpacing.lg),
                _H1ReportsSection(reports: profile.recentReports),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _ManualLogButton(onPressed: onLogManual),
      ],
    );
  }
}

class _HtbProfileCard extends StatelessWidget {
  const _HtbProfileCard({required this.profile});

  final HackTheBoxProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AvatarRing(
                imageUrl: profile.avatarUrl,
                fallback: profile.username.isNotEmpty
                    ? profile.username[0].toUpperCase()
                    : '?',
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.username,
                      style: AppTypography.headingMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _SecurityChip(label: profile.rank.toUpperCase()),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${profile.streak} day streak',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatsGrid(
            items: [
              _StatItem(label: 'Machines', value: '${profile.machinesOwned}'),
              _StatItem(
                label: 'Challenges',
                value: '${profile.challengesSolved}',
              ),
              _StatItem(
                label: 'Global Rank',
                value: profile.globalRank > 0
                    ? '#${_formatRank(profile.globalRank)}'
                    : '—',
              ),
              _StatItem(
                label: 'Points',
                value: '${profile.points}',
                accent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HtbSkillCoverageCard extends StatelessWidget {
  const _HtbSkillCoverageCard({required this.coverage});

  final Map<String, int> coverage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = coverage.values.fold<int>(0, (sum, value) => sum + value);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SKILL COVERAGE',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'TOTAL: $total',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _htbSkillKeys.map((skill) {
              final owned = coverage[skill] ?? 0;
              final active = owned > 0;
              return Container(
                width: (MediaQuery.sizeOf(context).width - AppSpacing.lg * 2 - AppSpacing.sm) / 2,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: active
                      ? _securityRed.withValues(alpha: 0.08)
                      : colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: active
                        ? _securityRed.withValues(alpha: 0.4)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      skill,
                      style: AppTypography.labelSmall.copyWith(
                        color: active
                            ? _securityRed
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$owned owned',
                      style: AppTypography.labelSmall.copyWith(
                        color: active
                            ? _securityRed.withValues(alpha: 0.7)
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _HtbRecentActivitySection extends StatelessWidget {
  const _HtbRecentActivitySection({required this.activity});

  final List<HackTheBoxActivity> activity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ACTIVITY',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (activity.isEmpty)
          Text(
            'No recent activity found.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...activity.map((item) => _HtbActivityTile(item: item)),
      ],
    );
  }
}

class _HtbActivityTile extends StatelessWidget {
  const _HtbActivityTile({required this.item});

  final HackTheBoxActivity item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = item.date.millisecondsSinceEpoch == 0
        ? '—'
        : DateFormat('yyyy-MM-dd').format(item.date.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _DifficultyDots(difficulty: item.difficulty),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _TypeChip(label: item.type),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      dateLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '+${item.points} pts',
            style: AppTypography.bodyMedium.copyWith(
              color: _securityRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _H1ProfileCard extends StatelessWidget {
  const _H1ProfileCard({required this.profile});

  final HackerOneProfile profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.username,
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatsGrid(
            items: [
              _StatItem(label: 'Reputation', value: '${profile.reputation}'),
              _StatItem(
                label: 'Signal',
                value: profile.signal.toStringAsFixed(1),
              ),
              _StatItem(
                label: 'Impact',
                value: profile.impact.toStringAsFixed(1),
              ),
              _StatItem(
                label: 'Thanks',
                value: '${profile.thanksCount}',
              ),
              _StatItem(
                label: 'Submitted',
                value: '${profile.reportsSubmitted}',
              ),
              _StatItem(
                label: 'Resolved',
                value: '${profile.reportsResolved}',
                accent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _H1BountyCard extends StatelessWidget {
  const _H1BountyCard({required this.summary});

  final BountySummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BOUNTY SUMMARY',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\$${summary.totalEarned.toStringAsFixed(0)} earned',
            style: AppTypography.headingMedium.copyWith(
              color: _securityRed,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...['critical', 'high', 'medium', 'low'].map((severity) {
            final amount = summary.bySeverity[severity] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    severity.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${amount.toStringAsFixed(0)}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _H1ReportsSection extends StatelessWidget {
  const _H1ReportsSection({required this.reports});

  final List<HackerOneReport> reports;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT REPORTS',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (reports.isEmpty)
          Text(
            'No recent reports found.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...reports.map((report) => _H1ReportTile(report: report)),
      ],
    );
  }
}

class _H1ReportTile extends StatelessWidget {
  const _H1ReportTile({required this.report});

  final HackerOneReport report;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = report.date.millisecondsSinceEpoch == 0
        ? '—'
        : DateFormat('yyyy-MM-dd').format(report.date.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurface,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _TypeChip(label: report.program),
              const SizedBox(width: AppSpacing.sm),
              _SeverityChip(severity: report.severity),
              const Spacer(),
              if (report.bounty != null)
                Text(
                  '\$${report.bounty!.toStringAsFixed(0)}',
                  style: AppTypography.labelLarge.copyWith(
                    color: _securityRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${report.status.toUpperCase()} · $dateLabel',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualLogButton extends StatelessWidget {
  const _ManualLogButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(
        'Log Activity Manually',
        style: AppTypography.labelLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}

class _ManualLogSheet extends StatefulWidget {
  const _ManualLogSheet({required this.onSubmit});

  final Future<void> Function(SecurityManualLog log) onSubmit;

  @override
  State<_ManualLogSheet> createState() => _ManualLogSheetState();
}

class _ManualLogSheetState extends State<_ManualLogSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _platform = 'htb';
  String _activityType = 'machine';
  String _difficulty = 'Medium';

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log Activity',
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: _platform,
              decoration: const InputDecoration(labelText: 'Platform'),
              items: const [
                DropdownMenuItem(value: 'htb', child: Text('HackTheBox')),
                DropdownMenuItem(value: 'h1', child: Text('HackerOne')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _platform = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _activityType,
              decoration: const InputDecoration(labelText: 'Activity type'),
              items: const [
                DropdownMenuItem(value: 'machine', child: Text('Machine')),
                DropdownMenuItem(value: 'challenge', child: Text('Challenge')),
                DropdownMenuItem(value: 'report', child: Text('Report')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _activityType = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: const [
                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                DropdownMenuItem(value: 'Insane', child: Text('Insane')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _difficulty = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () async {
                if (!(_formKey.currentState?.validate() ?? false)) {
                  return;
                }
                await widget.onSubmit(
                  SecurityManualLog(
                    platform: _platform,
                    activityType: _activityType,
                    name: _nameController.text.trim(),
                    difficulty: _difficulty,
                    notes: _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim(),
                  ),
                );
              },
              child: const Text('Save log'),
            ),
          ],
        ),
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
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({required this.imageUrl, required this.fallback});

  final String imageUrl;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _securityRed, width: 2),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundImage:
            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child: imageUrl.isEmpty ? Text(fallback) : null,
      ),
    );
  }
}

class _SecurityChip extends StatelessWidget {
  const _SecurityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _securityRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: _securityRed.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: _securityRed,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      'critical' => _securityRed,
      'high' => Colors.orange,
      'medium' => Colors.amber,
      'low' => Colors.blueGrey,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        severity.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filled = switch (difficulty.toLowerCase()) {
      'easy' => 1,
      'medium' => 2,
      'hard' => 3,
      'insane' => 3,
      _ => 1,
    };
    final color = switch (difficulty.toLowerCase()) {
      'easy' => Colors.green,
      'medium' => Colors.amber,
      'hard' => Colors.red,
      'insane' => Colors.red,
      _ => colorScheme.onSurfaceVariant,
    };

    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < filled
                ? color
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: colorScheme.surfaceContainerHigh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.value,
                style: AppTypography.headingMedium.copyWith(
                  color: item.accent ? _securityRed : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

String _formatRank(int rank) {
  if (rank >= 1000) {
    final thousands = rank / 1000;
    return '${thousands.toStringAsFixed(1)}k';
  }
  return '$rank';
}
