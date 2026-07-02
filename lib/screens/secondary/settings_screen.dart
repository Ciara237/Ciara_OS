import 'package:ciaraos/providers/onboarding_provider.dart';
import 'package:ciaraos/providers/theme_provider.dart';
import 'package:ciaraos/services/data_management_service.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/services/profile_preferences.dart';
import 'package:ciaraos/services/settings_preferences.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/navigation/minimal_back_header.dart';
import 'package:ciaraos/widgets/navigation/primary_drawer.dart';
import 'package:ciaraos/widgets/today/today_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _githubUrl = 'https://github.com/Ciara237/Ciara_OS';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _prefsLoaded = false;
  late final TextEditingController _confirmController;
  bool _confirmError = false;
  String _profileTagline = defaultProfileTagline;
  String _githubUsername = defaultGithubUsername;
  bool _isEditingGithubUsername = false;
  late final TextEditingController _githubUsernameController;

  @override
  void initState() {
    super.initState();
    _confirmController = TextEditingController();
    _githubUsernameController = TextEditingController();
    _loadPreferences();
  }

  @override
  void dispose() {
    _confirmController.dispose();
    _githubUsernameController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _notificationsEnabled =
          prefs.getBool(notificationsEnabledPreferenceKey) ?? false;
      _profileTagline =
          prefs.getString(profileTaglinePreferenceKey) ?? defaultProfileTagline;
      _githubUsername =
          prefs.getString(githubUsernamePreferenceKey) ?? defaultGithubUsername;
      _githubUsernameController.text = _githubUsername;
      _prefsLoaded = true;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    ref.read(themeModeProvider.notifier).state = mode;
    await saveThemeMode(mode);
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsEnabledPreferenceKey, value);
    setState(() => _notificationsEnabled = value);
    if (value && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications coming in a future update.'),
        ),
      );
    }
  }

  Future<void> _saveGithubUsername() async {
    final normalized = normalizeGithubUsername(_githubUsernameController.text);
    if (!isValidGithubUsername(normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GitHub username cannot contain spaces or @.'),
        ),
      );
      return;
    }

    await ref.read(profileProvider.notifier).saveGithubUsername(normalized);
    if (!mounted) {
      return;
    }
    setState(() {
      _githubUsername = normalized;
      _githubUsernameController.text = normalized;
      _isEditingGithubUsername = false;
    });
  }

  void _startEditingGithubUsername() {
    _githubUsernameController.text = _githubUsername;
    setState(() => _isEditingGithubUsername = true);
  }

  void _cancelGithubUsernameEdit() {
    _githubUsernameController.text = _githubUsername;
    setState(() => _isEditingGithubUsername = false);
  }

  Future<void> _openGithub() async {
    final uri = Uri.parse(_githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _resetOnboarding() async {
    await ref.read(onboardingNotifierProvider).reset();
    if (!mounted) {
      return;
    }
    context.go('/onboarding');
  }

  Future<void> _clearAllData() async {
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(
            'Clear all data?',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This will permanently delete all tasks, projects, '
            'opportunities, and reviews. This cannot be undone.',
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
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (firstConfirmed != true || !mounted) {
      return;
    }

    _confirmController.clear();
    setState(() => _confirmError = false);

    final typedConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Confirm deletion',
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type DELETE to confirm.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _confirmController,
                    autofocus: true,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      errorText: _confirmError ? 'Type DELETE exactly' : null,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    onChanged: (_) {
                      if (_confirmError) {
                        setDialogState(() {});
                        setState(() => _confirmError = false);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (_confirmController.text.trim() != 'DELETE') {
                      setState(() => _confirmError = true);
                      setDialogState(() {});
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: const Text('Delete everything'),
                ),
              ],
            );
          },
        );
      },
    );

    if (typedConfirmed != true || !mounted) {
      return;
    }

    await ref.read(dataManagementServiceProvider).clearAllData();
    await ref.read(onboardingNotifierProvider).reset();
    if (!mounted) {
      return;
    }
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);

    final openedFromStack = GoRouter.of(context).canPop();

    if (!_prefsLoaded) {
      return Scaffold(
        drawer: openedFromStack ? null : const PrimaryDrawer(),
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            if (openedFromStack)
              const MinimalBackHeader()
            else
              const TodayHeader(),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: openedFromStack ? null : const PrimaryDrawer(),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          if (openedFromStack)
            const MinimalBackHeader()
          else
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
                      const _SettingsHeader(),
                const SizedBox(height: AppSpacing.reviewGap),
                _SettingsSection(
                  label: 'APPEARANCE',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      _ThemeChip(
                        label: 'Light',
                        selected: themeMode == ThemeMode.light,
                        onTap: () => _setThemeMode(ThemeMode.light),
                      ),
                      _ThemeChip(
                        label: 'Dark',
                        selected: themeMode == ThemeMode.dark,
                        onTap: () => _setThemeMode(ThemeMode.dark),
                      ),
                      _ThemeChip(
                        label: 'System',
                        selected: themeMode == ThemeMode.system,
                        onTap: () => _setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _SettingsSection(
                  label: 'NOTIFICATIONS',
                  child: _SettingsSwitchRow(
                    title: 'Deadline reminders',
                    subtitle: 'Receive alerts for tasks due today',
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _SettingsSection(
                  label: 'DATA',
                  child: Column(
                    children: [
                      _SettingsActionRow(
                        title: 'Export Data',
                        subtitle: 'Download all your tasks and reviews as JSON',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Export coming in a future update.',
                              ),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: AppSpacing.lg,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                      _SettingsActionRow(
                        title: 'Clear All Data',
                        subtitle: 'Permanently delete all local storage data',
                        titleColor: colorScheme.error,
                        onTap: _clearAllData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _SettingsSection(
                  label: 'INTEGRATIONS',
                  child: _isEditingGithubUsername
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _githubUsernameController,
                                autofocus: true,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'GitHub Username',
                                  isDense: true,
                                ),
                                onSubmitted: (_) => _saveGithubUsername(),
                              ),
                            ),
                            IconButton(
                              onPressed: _saveGithubUsername,
                              icon: Icon(Icons.check, color: colorScheme.primary),
                            ),
                            IconButton(
                              onPressed: _cancelGithubUsernameEdit,
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : _SettingsActionRow(
                          title: 'GitHub Username',
                          subtitle: _githubUsername,
                          onTap: _startEditingGithubUsername,
                          trailing: Icon(
                            Icons.edit_outlined,
                            size: AppSpacing.md,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _SettingsSection(
                  label: 'DEVELOPER',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: 'App Version', value: 'v1.0.0'),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(label: 'Flutter', value: 'Flutter 3.x'),
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        label: 'Database',
                        value: 'Drift (SQLite) — Local',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SettingsActionRow(
                        title: 'Reset Onboarding',
                        subtitle: 'Return to the first-launch intro flow',
                        onTap: _resetOnboarding,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.reviewGap),
                _SettingsSection(
                  label: 'ABOUT',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ciara OS',
                        style: AppTypography.headingMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _profileTagline,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Designed and built by Ciara M.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InkWell(
                        onTap: _openGithub,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            _githubUrl,
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Built with Flutter, Drift, Riverpod',
                        style: AppTypography.labelLarge.copyWith(
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
      ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'SETTINGS',
      style: AppTypography.monospace.copyWith(
        color: colorScheme.onSurface,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
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

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

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
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Widget? trailing;

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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: titleColor ?? colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
