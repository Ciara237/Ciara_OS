import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Project status chip colors — match project_card.dart; not domain/theme tokens.
abstract final class _ProjectStatusColors {
  // Intentionally matches Opportunities active status color (#10B981).
  static const Color active = Color(0xFF10B981);
  static const Color paused = Color(0xFFF59E0B);
  static const Color shipped = Color(0xFF3B82F6);
  static const Color archived = Color(0xFF64748B);
}

class ProjectCreateEditScreen extends ConsumerStatefulWidget {
  const ProjectCreateEditScreen({super.key, this.projectId});

  final String? projectId;

  bool get isEditMode => projectId != null;

  @override
  ConsumerState<ProjectCreateEditScreen> createState() =>
      _ProjectCreateEditScreenState();
}

class _ProjectCreateEditScreenState extends ConsumerState<ProjectCreateEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _nextActionController;
  late final TextEditingController _linkController;
  late final TextEditingController _descriptionController;

  Domain _selectedDomain = Domain.other;
  ProjectStatus _selectedStatus = ProjectStatus.active;
  bool _isSaving = false;
  bool _nameError = false;
  bool _linkError = false;
  bool _didPopulate = false;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nextActionController = TextEditingController();
    _linkController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nextActionController.dispose();
    _linkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _populateFromProject(Project project) {
    _nameController.text = project.name;
    _nextActionController.text = project.nextAction ?? '';
    _linkController.text = project.externalLink ?? '';
    _descriptionController.text = project.description ?? '';
    _selectedDomain = project.domain;
    _selectedStatus = project.status;
    _createdAt = project.createdAt;
  }

  bool _isValidUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final link = _linkController.text.trim();
    final hasNameError = name.isEmpty;
    final hasLinkError = link.isNotEmpty && !_isValidUrl(link);

    if (hasNameError || hasLinkError) {
      setState(() {
        _nameError = hasNameError;
        _linkError = hasLinkError;
      });
      return;
    }

    setState(() {
      _nameError = false;
      _linkError = false;
      _isSaving = true;
    });

    final repository = ref.read(projectRepositoryProvider);
    final now = DateTime.now();
    final nextAction = _nextActionController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      if (widget.isEditMode) {
        final project = Project(
          id: int.parse(widget.projectId!),
          name: name,
          domain: _selectedDomain,
          status: _selectedStatus,
          nextAction: nextAction.isEmpty ? null : nextAction,
          externalLink: link.isEmpty ? null : link,
          description: description.isEmpty ? null : description,
          createdAt: _createdAt ?? now,
          updatedAt: now,
        );
        await repository.update(project.toCompanion());
      } else {
        final project = Project(
          id: 0,
          name: name,
          domain: _selectedDomain,
          status: _selectedStatus,
          nextAction: nextAction.isEmpty ? null : nextAction,
          externalLink: link.isEmpty ? null : link,
          description: description.isEmpty ? null : description,
          createdAt: now,
          updatedAt: now,
        );
        final projectId =
            await repository.insert(project.toCompanion(forInsert: true));

        if (nextAction.isNotEmpty) {
          await ref.read(taskRepositoryProvider).insert(
                Task(
                  id: 0,
                  title: nextAction,
                  domain: _selectedDomain,
                  status: TaskStatus.notStarted,
                  priority: Priority.medium,
                  started: false,
                  today: false,
                  projectId: projectId,
                  postponeCount: 0,
                  createdAt: now,
                  updatedAt: now,
                ).toCompanion(forInsert: true),
              );
        }
      }

      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteProject() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete this project?',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This cannot be undone.',
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

    await ref.read(projectRepositoryProvider).delete(int.parse(widget.projectId!));
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isEditMode) {
      final projectId = int.parse(widget.projectId!);
      final projectAsync = ref.watch(projectByIdProvider(projectId));

      ref.listen(projectByIdProvider(projectId), (previous, next) {
        next.whenData((project) {
          if (project != null && !_didPopulate && mounted) {
            setState(() {
              _didPopulate = true;
              _populateFromProject(project);
            });
          }
        });
      });

      if (projectAsync.isLoading && !_didPopulate) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (projectAsync.hasError || projectAsync.value == null) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Center(
            child: Text(
              'Could not load project.',
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ProjectFormHeader(
              title: widget.isEditMode ? 'Edit Project' : 'New Project',
              isSaving: _isSaving,
              onBack: () => context.pop(),
              onSave: _save,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                children: [
                  const _FormFieldLabel(text: 'PROJECT NAME'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _nameController,
                    maxLines: 1,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: _fieldDecoration(
                      context,
                      hint: 'What are you building?',
                    ),
                    onChanged: (_) {
                      if (_nameError) {
                        setState(() => _nameError = false);
                      }
                    },
                  ),
                  if (_nameError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Name is required',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'DOMAIN'),
                  const SizedBox(height: AppSpacing.sm),
                  _DomainChipRow(
                    selected: _selectedDomain,
                    onSelected: (domain) =>
                        setState(() => _selectedDomain = domain),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'STATUS'),
                  const SizedBox(height: AppSpacing.sm),
                  _ProjectStatusChipRow(
                    selected: _selectedStatus,
                    onSelected: (status) =>
                        setState(() => _selectedStatus = status),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'NEXT ACTION'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _nextActionController,
                    maxLines: 1,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: _fieldDecoration(
                      context,
                      hint: "What's the immediate next step?",
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'EXTERNAL LINK'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _linkController,
                    maxLines: 1,
                    keyboardType: TextInputType.url,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: _fieldDecoration(
                      context,
                      hint: 'https://github.com/...',
                    ),
                    onChanged: (_) {
                      if (_linkError) {
                        setState(() => _linkError = false);
                      }
                    },
                  ),
                  if (_linkError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Enter a valid URL (https://...)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'DESCRIPTION'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: null,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: _fieldDecoration(
                      context,
                      hint: 'What is this project about?',
                    ),
                  ),
                  if (widget.isEditMode) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _deleteProject,
                        child: Text(
                          'DELETE PROJECT',
                          style: AppTypography.labelLarge.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(BuildContext context, {required String hint}) {
  final colorScheme = Theme.of(context).colorScheme;

  return InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.bodyLarge.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    filled: true,
    fillColor: colorScheme.surfaceContainerLowest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(color: colorScheme.primary),
    ),
  );
}

class _ProjectFormHeader extends StatelessWidget {
  const _ProjectFormHeader({
    required this.title,
    required this.isSaving,
    required this.onBack,
    required this.onSave,
  });

  final String title;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          ),
          Expanded(
            child: Text(
              title,
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
                fontFamily: AppTypography.monospace.fontFamily,
              ),
            ),
          ),
          TextButton(
            onPressed: isSaving ? null : onSave,
            child: Text(
              'SAVE',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormFieldLabel extends StatelessWidget {
  const _FormFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      text,
      style: AppTypography.labelSmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DomainChipRow extends StatelessWidget {
  const _DomainChipRow({
    required this.selected,
    required this.onSelected,
  });

  final Domain selected;
  final ValueChanged<Domain> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final domain in Domain.values)
          _DomainChip(
            domain: domain,
            isSelected: domain == selected,
            onTap: () => onSelected(domain),
          ),
      ],
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({
    required this.domain,
    required this.isSelected,
    required this.onTap,
  });

  final Domain domain;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(domain);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? domainColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: domainColor),
        ),
        child: Text(
          domainShortLabel(domain),
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? colorScheme.onPrimary : domainColor,
          ),
        ),
      ),
    );
  }
}

class _ProjectStatusChipRow extends StatelessWidget {
  const _ProjectStatusChipRow({
    required this.selected,
    required this.onSelected,
  });

  final ProjectStatus selected;
  final ValueChanged<ProjectStatus> onSelected;

  static Color _colorFor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.active => _ProjectStatusColors.active,
      ProjectStatus.paused => _ProjectStatusColors.paused,
      ProjectStatus.shipped => _ProjectStatusColors.shipped,
      ProjectStatus.archived => _ProjectStatusColors.archived,
    };
  }

  static String _labelFor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.active => 'ACTIVE',
      ProjectStatus.paused => 'PAUSED',
      ProjectStatus.shipped => 'SHIPPED',
      ProjectStatus.archived => 'ARCHIVED',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final status in ProjectStatus.values)
          _StatusChip(
            label: _labelFor(status),
            color: _colorFor(status),
            isSelected: status == selected,
            selectedTextColor: colorScheme.onPrimary,
            onTap: () => onSelected(status),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.selectedTextColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final Color selectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? selectedTextColor : color,
          ),
        ),
      ),
    );
  }
}
