import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TaskCreateEditScreen extends ConsumerStatefulWidget {
  const TaskCreateEditScreen({
    super.key,
    this.taskId,
    this.initialProjectId,
  });

  final String? taskId;
  final String? initialProjectId;

  bool get isEditMode => taskId != null;

  @override
  ConsumerState<TaskCreateEditScreen> createState() =>
      _TaskCreateEditScreenState();
}

class _TaskCreateEditScreenState extends ConsumerState<TaskCreateEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;

  Domain _selectedDomain = Domain.other;
  Priority _selectedPriority = Priority.medium;
  TaskStatus _selectedStatus = TaskStatus.notStarted;
  DateTime? _selectedDeadline;
  int? _selectedProjectId;
  bool _todayFlag = false;
  bool _isSaving = false;
  bool _titleError = false;
  bool _didPopulate = false;
  bool _started = false;
  int _postponeCount = 0;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    if (!widget.isEditMode && widget.initialProjectId != null) {
      _selectedProjectId = int.tryParse(widget.initialProjectId!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateFromTask(Task task) {
    _titleController.text = task.title;
    _notesController.text = task.notes ?? '';
    _selectedDomain = task.domain;
    _selectedPriority = task.priority;
    _selectedStatus = task.status;
    _selectedDeadline = task.deadline;
    _selectedProjectId = task.projectId;
    _todayFlag = task.today;
    _started = task.started;
    _postponeCount = task.postponeCount;
    _createdAt = task.createdAt;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final initial = _selectedDeadline ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = true);
      return;
    }

    setState(() {
      _titleError = false;
      _isSaving = true;
    });

    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now();

    try {
      if (widget.isEditMode) {
        final task = Task(
          id: int.parse(widget.taskId!),
          title: title,
          domain: _selectedDomain,
          status: _selectedStatus,
          priority: _selectedPriority,
          started: _started,
          today: _todayFlag,
          deadline: _selectedDeadline,
          projectId: _selectedProjectId,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          postponeCount: _postponeCount,
          createdAt: _createdAt ?? now,
          updatedAt: now,
        );
        await repository.update(task.toCompanion());
      } else {
        final task = Task(
          id: 0,
          title: title,
          domain: _selectedDomain,
          status: TaskStatus.notStarted,
          priority: _selectedPriority,
          started: false,
          today: _todayFlag,
          deadline: _selectedDeadline,
          projectId: _selectedProjectId,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          postponeCount: 0,
          createdAt: now,
          updatedAt: now,
        );
        await repository.insert(task.toCompanion(forInsert: true));
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

  Future<void> _deleteTask() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete this task?',
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

    await ref.read(taskRepositoryProvider).delete(int.parse(widget.taskId!));
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectsAsync = ref.watch(allProjectsProvider);

    if (widget.isEditMode) {
      final taskId = int.parse(widget.taskId!);
      final taskAsync = ref.watch(taskByIdProvider(taskId));

      ref.listen(taskByIdProvider(taskId), (previous, next) {
        next.whenData((task) {
          if (task != null && !_didPopulate && mounted) {
            setState(() {
              _didPopulate = true;
              _populateFromTask(task);
            });
          }
        });
      });

      if (taskAsync.isLoading && !_didPopulate) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (taskAsync.hasError || taskAsync.value == null) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Center(
            child: Text(
              'Could not load task.',
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
            _TaskFormHeader(
              title: widget.isEditMode ? 'Edit Task' : 'New Task',
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
                  const _FormFieldLabel(text: 'TASK TITLE'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _titleController,
                    maxLines: 1,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
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
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                    onChanged: (_) {
                      if (_titleError) {
                        setState(() => _titleError = false);
                      }
                    },
                  ),
                  if (_titleError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Title is required',
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
                  const _FormFieldLabel(text: 'PRIORITY'),
                  const SizedBox(height: AppSpacing.sm),
                  _PriorityChipRow(
                    selected: _selectedPriority,
                    onSelected: (priority) =>
                        setState(() => _selectedPriority = priority),
                  ),
                  if (widget.isEditMode) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const _FormFieldLabel(text: 'STATUS'),
                    const SizedBox(height: AppSpacing.sm),
                    _StatusChipRow(
                      selected: _selectedStatus,
                      onSelected: (status) =>
                          setState(() => _selectedStatus = status),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'DEADLINE'),
                  const SizedBox(height: AppSpacing.sm),
                  _DeadlinePickerRow(
                    deadline: _selectedDeadline,
                    onTap: _pickDeadline,
                    onClear: _selectedDeadline == null
                        ? null
                        : () => setState(() => _selectedDeadline = null),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'LINKED PROJECT'),
                  const SizedBox(height: AppSpacing.sm),
                  _ProjectDropdown(
                    projects: projectsAsync.value ?? const [],
                    selectedProjectId: _selectedProjectId,
                    onChanged: (projectId) =>
                        setState(() => _selectedProjectId = projectId),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'FLAG FOR TODAY'),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _todayFlag,
                    onChanged: (value) => setState(() => _todayFlag = value),
                    title: Text(
                      'Show on Today screen',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'NOTES'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: null,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add any context, links, or details...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
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
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                  ),
                  if (widget.isEditMode) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _deleteTask,
                        child: Text(
                          'DELETE TASK',
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

class _TaskFormHeader extends StatelessWidget {
  const _TaskFormHeader({
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

class _PriorityChipRow extends StatelessWidget {
  const _PriorityChipRow({
    required this.selected,
    required this.onSelected,
  });

  final Priority selected;
  final ValueChanged<Priority> onSelected;

  static Color _colorFor(Priority priority) {
    return switch (priority) {
      Priority.low => AppColors.priorityLow,
      Priority.medium => AppColors.priorityMedium,
      Priority.high => AppColors.priorityHigh,
      Priority.critical => AppColors.priorityCritical,
    };
  }

  static String _labelFor(Priority priority) {
    return switch (priority) {
      Priority.low => 'LOW',
      Priority.medium => 'MEDIUM',
      Priority.high => 'HIGH',
      Priority.critical => 'CRITICAL',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final priority in Priority.values)
          _SelectableChip(
            label: _labelFor(priority),
            color: _colorFor(priority),
            isSelected: priority == selected,
            selectedTextColor: colorScheme.onPrimary,
            onTap: () => onSelected(priority),
          ),
      ],
    );
  }
}

class _StatusChipRow extends StatelessWidget {
  const _StatusChipRow({
    required this.selected,
    required this.onSelected,
  });

  final TaskStatus selected;
  final ValueChanged<TaskStatus> onSelected;

  static String _labelFor(TaskStatus status) {
    return switch (status) {
      TaskStatus.notStarted => 'NOT STARTED',
      TaskStatus.inProgress => 'IN PROGRESS',
      TaskStatus.done => 'DONE',
      TaskStatus.stuck => 'STUCK',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final status in TaskStatus.values)
          _SelectableChip(
            label: _labelFor(status),
            color: colorScheme.primary,
            isSelected: status == selected,
            selectedTextColor: colorScheme.onPrimary,
            onTap: () => onSelected(status),
          ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
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

class _DeadlinePickerRow extends StatelessWidget {
  const _DeadlinePickerRow({
    required this.deadline,
    required this.onTap,
    this.onClear,
  });

  final DateTime? deadline;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = deadline == null
        ? 'No deadline set'
        : DateFormat('MMM d, yyyy').format(deadline!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: AppSpacing.lg,
              color: deadline == null
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: deadline == null
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (onClear != null)
              IconButton(
                onPressed: onClear,
                icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDropdown extends StatelessWidget {
  const _ProjectDropdown({
    required this.projects,
    required this.selectedProjectId,
    required this.onChanged,
  });

  final List<Project> projects;
  final int? selectedProjectId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeProjects =
        projects.where((p) => p.status == ProjectStatus.active).toList();
    final validProjectId = activeProjects.any((p) => p.id == selectedProjectId)
        ? selectedProjectId
        : null;

    if (activeProjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(
          'No projects yet',
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: validProjectId,
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'None',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            for (final project in activeProjects)
              DropdownMenuItem<int?>(
                value: project.id,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: context.domainColor(project.domain),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        project.name,
                        style: AppTypography.bodyLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
