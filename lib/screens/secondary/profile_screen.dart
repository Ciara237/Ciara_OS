import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/theme_provider.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/services/profile_preferences.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/widgets/profile/profile_name_prompt_dialog.dart';
import 'package:ciaraos/widgets/navigation/primary_drawer.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _githubUrl = 'https://github.com/Ciara237/Ciara_OS';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _avatarSize = 64.0;

  bool _isEditingTagline = false;
  bool _isEditingName = false;
  late final TextEditingController _taglineController;
  late final TextEditingController _nameController;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _taglineController = TextEditingController();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).reload();
    });
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveTagline(String value) async {
    await ref.read(profileProvider.notifier).saveTagline(value);
    if (!mounted) {
      return;
    }
    setState(() => _isEditingTagline = false);
  }

  Future<void> _saveName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await ref.read(profileProvider.notifier).saveDisplayName(trimmed);
    if (!mounted) {
      return;
    }
    setState(() => _isEditingName = false);
  }

  void _startEditingTagline(String currentTagline) {
    _taglineController.text = currentTagline;
    setState(() => _isEditingTagline = true);
  }

  Future<void> _confirmTaglineEdit() async {
    await _saveTagline(_taglineController.text);
  }

  void _cancelTaglineEdit(String currentTagline) {
    _taglineController.text = currentTagline;
    setState(() => _isEditingTagline = false);
  }

  void _startEditingName(String currentName) {
    _nameController.text = currentName;
    setState(() => _isEditingName = true);
  }

  Future<void> _confirmNameEdit() async {
    await _saveName(_nameController.text);
  }

  void _cancelNameEdit(String currentName) {
    _nameController.text = currentName;
    setState(() => _isEditingName = false);
  }

  Future<void> _promptForName() async {
    await showProfileNamePromptDialog(context, ref, isFirstTime: false);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    ref.read(themeModeProvider.notifier).state = mode;
    await saveThemeMode(mode);
  }

  Future<void> _openGithub() async {
    final uri = Uri.parse(_githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMonday = mondayOfWeek(DateTime.now());
    final tasksAsync = ref.watch(allTasksProvider);
    final projectsAsync = ref.watch(allProjectsProvider);
    final opportunitiesAsync = ref.watch(allOpportunitiesProvider);
    final weekTasksAsync = ref.watch(weekTasksProvider(currentMonday));
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(profileProvider);

    if (!_profileLoaded && profile.isNameConfigured) {
      _profileLoaded = true;
    }

    if (!_profileLoaded && profile.displayName.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _profileLoaded = true);
        }
      });
    }

    final isReady = profile.isNameConfigured || profile.displayName.isNotEmpty;

    if (!isReady) {
      return Scaffold(
        drawer: const PrimaryDrawer(),
        backgroundColor: colorScheme.surface,
        body: const Column(
          children: [
            TodayHeader(),
            Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

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
                  isEditingName: _isEditingName,
                  isEditingTagline: _isEditingTagline,
                  nameController: _nameController,
                  taglineController: _taglineController,
                  onStartEditName: () =>
                      _startEditingName(profile.resolvedDisplayName),
                  onConfirmNameEdit: _confirmNameEdit,
                  onCancelNameEdit: () =>
                      _cancelNameEdit(profile.resolvedDisplayName),
                  onPromptForName: _promptForName,
                  onStartEditTagline: () => _startEditingTagline(profile.tagline),
                  onConfirmTaglineEdit: _confirmTaglineEdit,
                  onCancelTaglineEdit: () =>
                      _cancelTaglineEdit(profile.tagline),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _QuickStatsRow(
                  tasksAsync: tasksAsync,
                  projectsAsync: projectsAsync,
                  opportunitiesAsync: opportunitiesAsync,
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                weekTasksAsync.when(
                  loading: () => const _SectionCard(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const _ThisWeekCard(
                    startedRatePercent: 0,
                    startedCount: 0,
                    totalCount: 0,
                  ),
                  data: (weekTasks) {
                    final startedCount =
                        weekTasks.where((task) => task.started).length;
                    final totalCount = weekTasks.length;
                    final rate = totalCount == 0
                        ? 0
                        : (startedRateForTasks(weekTasks) * 100).round();
                    return _ThisWeekCard(
                      startedRatePercent: rate,
                      startedCount: startedCount,
                      totalCount: totalCount,
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
                _AppearanceSection(
                  themeMode: themeMode,
                  onThemeSelected: _setThemeMode,
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _AboutSection(onGithubTap: _openGithub),
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
    required this.tagline,
    required this.isEditingTagline,
    required this.taglineController,
    required this.onStartEdit,
    required this.onConfirmEdit,
    required this.onCancelEdit,
  });

  final String tagline;
  final bool isEditingTagline;
  final TextEditingController taglineController;
  final VoidCallback onStartEdit;
  final VoidCallback onConfirmEdit;
  final VoidCallback onCancelEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        CircleAvatar(
          radius: _ProfileScreenState._avatarSize / 2,
          backgroundColor: AppColors.darkPrimary,
          child: Text(
            'CM',
            style: AppTypography.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ciara M.',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isEditingTagline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taglineController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                    onSubmitted: (_) => onConfirmEdit(),
                  ),
                ),
                IconButton(
                  onPressed: onConfirmEdit,
                  icon: Icon(Icons.check, color: colorScheme.primary),
                ),
                IconButton(
                  onPressed: onCancelEdit,
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: onStartEdit,
                icon: Icon(
                  Icons.edit_outlined,
                  size: AppSpacing.md,
                  color: colorScheme.onSurfaceVariant,
                ),
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                constraints: const BoxConstraints(),
              ),
            ],
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
    required this.startedRatePercent,
    required this.startedCount,
    required this.totalCount,
  });

  final int startedRatePercent;
  final int startedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = totalCount == 0
        ? 0.0
        : (startedRatePercent / 100).clamp(0.0, 1.0);

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
            '$startedRatePercent%',
            style: AppTypography.headingLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$startedCount / $totalCount tasks started',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: AppSpacing.xs,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
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

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection({
    required this.themeMode,
    required this.onThemeSelected,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPEARANCE',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _ThemeChip(
                label: 'Light',
                selected: themeMode == ThemeMode.light,
                onTap: () => onThemeSelected(ThemeMode.light),
              ),
              _ThemeChip(
                label: 'Dark',
                selected: themeMode == ThemeMode.dark,
                onTap: () => onThemeSelected(ThemeMode.dark),
              ),
              _ThemeChip(
                label: 'System',
                selected: themeMode == ThemeMode.system,
                onTap: () => onThemeSelected(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: colorScheme.surfaceContainerLowest,
      selectedColor: colorScheme.primary,
      side: BorderSide(
        color: selected
            ? colorScheme.primary
            : colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.onGithubTap});

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
                _githubUrl,
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
