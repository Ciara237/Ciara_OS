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
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Status dot colors — match project_card.dart.
abstract final class _ProjectStatusColors {
  static const Color active = Color(0xFF10B981);
  static const Color paused = Color(0xFFF59E0B);
  static const Color shipped = Color(0xFF3B82F6);
  static const Color archived = Color(0xFF64748B);
}

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  bool _isEditingNextAction = false;
  bool _isEditingDescription = false;
  late final TextEditingController _nextActionController;
  late final TextEditingController _descriptionController;

  int get _id => int.parse(widget.projectId);

  @override
  void initState() {
    super.initState();
    _nextActionController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nextActionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _persistProject(Project project) async {
    await ref.read(projectRepositoryProvider).update(
          project.copyWith(updatedAt: DateTime.now()).toCompanion(),
        );
    ref.invalidate(projectByIdProvider(_id));
  }

  Future<void> _saveNextAction(Project project) async {
    final text = _nextActionController.text.trim();
    await _persistProject(
      project.copyWith(
        nextAction: text.isEmpty ? null : text,
        clearNextAction: text.isEmpty,
      ),
    );
    if (mounted) {
      setState(() => _isEditingNextAction = false);
    }
  }

  Future<void> _saveDescription(Project project) async {
    final text = _descriptionController.text.trim();
    await _persistProject(
      project.copyWith(
        description: text.isEmpty ? null : text,
        clearDescription: text.isEmpty,
      ),
    );
    if (mounted) {
      setState(() => _isEditingDescription = false);
    }
  }

  Future<void> _archiveProject(Project project) async {
    await _persistProject(
      project.copyWith(status: ProjectStatus.archived),
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project archived')),
    );
  }

  Future<void> _deleteProject(Project project) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete project?',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This will permanently remove "${project.name}".',
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

    await ref.read(projectRepositoryProvider).delete(project.id);
    if (!mounted) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectAsync = ref.watch(projectByIdProvider(_id));
    final tasksAsync = ref.watch(allTasksProvider);

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          ProjectDetailHeader(projectId: widget.projectId),
          Expanded(
            child: projectAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  'Could not load project.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (project) {
                if (project == null) {
                  return Center(
                    child: Text(
                      'Project not found.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                if (!_isEditingNextAction &&
                    _nextActionController.text.isEmpty &&
                    project.nextAction != null) {
                  _nextActionController.text = project.nextAction!;
                }
                if (!_isEditingDescription &&
                    _descriptionController.text.isEmpty &&
                    project.description != null) {
                  _descriptionController.text = project.description!;
                }

                final linkedTasks = tasksAsync.maybeWhen(
                  data: (tasks) => tasks
                      .where((task) => task.projectId == project.id)
                      .toList()
                    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
                  orElse: () => <Task>[],
                );

                final showDescriptionCard =
                    project.description != null || _isEditingDescription;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  children: [
                    ProjectIdentitySection(project: project),
                    const SizedBox(height: AppSpacing.lg),
                    ProjectOpenButton(externalLink: project.externalLink),
                    const SizedBox(height: AppSpacing.lg),
                    ProjectNextActionCard(
                      isEditing: _isEditingNextAction,
                      nextAction: project.nextAction,
                      controller: _nextActionController,
                      onEdit: () => setState(() => _isEditingNextAction = true),
                      onSave: () => _saveNextAction(project),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ProjectLinkedTasksCard(
                      projectId: project.id,
                      linkedTasks: linkedTasks,
                      isLoading: tasksAsync.isLoading,
                    ),
                    if (showDescriptionCard) ...[
                      const SizedBox(height: AppSpacing.lg),
                      ProjectDescriptionCard(
                        isEditing: _isEditingDescription,
                        description: project.description,
                        controller: _descriptionController,
                        onEdit: () =>
                            setState(() => _isEditingDescription = true),
                        onSave: () => _saveDescription(project),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ProjectMetadataSection(project: project),
                    const SizedBox(height: AppSpacing.xl),
                    ProjectDangerZone(
                      isArchived: project.status == ProjectStatus.archived,
                      onArchive: () => _archiveProject(project),
                      onDelete: () => _deleteProject(project),
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

class ProjectDetailHeader extends StatelessWidget {
  const ProjectDetailHeader({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: AppSpacing.appBarHeight,
      color: colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          ),
          Icon(Icons.terminal, color: colorScheme.primary, size: AppSpacing.lg),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Ciara OS',
            style: AppTypography.monospace.copyWith(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push('/projects/$projectId/edit'),
            icon: Icon(Icons.edit, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class ProjectIdentitySection extends StatelessWidget {
  const ProjectIdentitySection({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(project.domain);
    final statusColor = projectStatusDotColor(project.status);
    final description = project.description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              domainIcon(project.domain),
              size: AppSpacing.md,
              color: domainColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              domainLabel(project.domain),
              style: AppTypography.labelSmall.copyWith(color: domainColor),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          project.name,
          style: AppTypography.displayLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Container(
              width: AppSpacing.sm,
              height: AppSpacing.sm,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              projectStatusLabel(project.status),
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class ProjectOpenButton extends StatelessWidget {
  const ProjectOpenButton({super.key, required this.externalLink});

  final String? externalLink;

  Future<void> _openLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const minHeight = 56.0;

    if (externalLink != null && externalLink!.trim().isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => _openLink(externalLink!),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(minHeight),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          child: Text(
            'OPEN PROJECT ↗',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(minHeight),
          foregroundColor: colorScheme.onSurfaceVariant,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Text(
          'No external link set',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DetailSurfaceCard extends StatelessWidget {
  const _DetailSurfaceCard({required this.child});

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

class ProjectNextActionCard extends StatelessWidget {
  const ProjectNextActionCard({
    super.key,
    required this.isEditing,
    required this.nextAction,
    required this.controller,
    required this.onEdit,
    required this.onSave,
  });

  final bool isEditing;
  final String? nextAction;
  final TextEditingController controller;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasNextAction = nextAction != null && nextAction!.trim().isNotEmpty;

    return _DetailSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'NEXT ACTION',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: isEditing ? onSave : onEdit,
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          if (isEditing)
            TextField(
              controller: controller,
              maxLines: 1,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "What's the immediate next step?",
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              hasNextAction ? nextAction! : 'No next action set.',
              style: AppTypography.bodyMedium.copyWith(
                color: hasNextAction
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontStyle: hasNextAction ? FontStyle.normal : FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class ProjectLinkedTasksCard extends StatelessWidget {
  const ProjectLinkedTasksCard({
    super.key,
    required this.projectId,
    required this.linkedTasks,
    required this.isLoading,
  });

  final int projectId;
  final List<Task> linkedTasks;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _DetailSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LINKED TASKS (${linkedTasks.length})',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (linkedTasks.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No tasks linked to this project.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () =>
                      context.push('/tasks/new?projectId=$projectId'),
                  child: Text(
                    '+ Add Task',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < linkedTasks.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _LinkedTaskRow(task: linkedTasks[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _LinkedTaskRow extends StatelessWidget {
  const _LinkedTaskRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/tasks/${task.id}'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: AppSpacing.taskBorderWidth,
                  decoration: BoxDecoration(
                    color: domainColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyLarge.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _TaskStatusChip(label: _taskStatusLabel(task.status)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
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

class ProjectDescriptionCard extends StatelessWidget {
  const ProjectDescriptionCard({
    super.key,
    required this.isEditing,
    required this.description,
    required this.controller,
    required this.onEdit,
    required this.onSave,
  });

  final bool isEditing;
  final String? description;
  final TextEditingController controller;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasDescription =
        description != null && description!.trim().isNotEmpty;

    return _DetailSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'DESCRIPTION',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: isEditing ? onSave : onEdit,
                icon: Icon(
                  isEditing ? Icons.check : Icons.edit,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          if (isEditing)
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: null,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'What is this project about?',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              hasDescription ? description! : 'No description added.',
              style: AppTypography.bodyMedium.copyWith(
                color: hasDescription
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontStyle:
                    hasDescription ? FontStyle.normal : FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

class ProjectMetadataSection extends StatelessWidget {
  const ProjectMetadataSection({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(project.domain);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetadataRow(
          label: 'CREATED',
          value: DateFormat('MMM d, yyyy').format(project.createdAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MetadataRow(
          label: 'LAST MODIFIED',
          value: relativeTimeLabel(project.updatedAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text(
              'DOMAIN',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              domainLabel(project.domain),
              style: AppTypography.labelSmall.copyWith(color: domainColor),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class ProjectDangerZone extends StatelessWidget {
  const ProjectDangerZone({
    super.key,
    required this.isArchived,
    required this.onArchive,
    required this.onDelete,
  });

  final bool isArchived;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const archiveColor = AppColors.priorityHigh;

    return Column(
      children: [
        if (!isArchived)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onArchive,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: archiveColor,
                side: const BorderSide(color: archiveColor),
              ),
              child: Text(
                'ARCHIVE PROJECT',
                style: AppTypography.labelLarge.copyWith(color: archiveColor),
              ),
            ),
          ),
        if (!isArchived) const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: onDelete,
            child: Text(
              'DELETE PROJECT',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Color projectStatusDotColor(ProjectStatus status) {
  return switch (status) {
    ProjectStatus.active => _ProjectStatusColors.active,
    ProjectStatus.paused => _ProjectStatusColors.paused,
    ProjectStatus.shipped => _ProjectStatusColors.shipped,
    ProjectStatus.archived => _ProjectStatusColors.archived,
  };
}

String projectStatusLabel(ProjectStatus status) {
  return switch (status) {
    ProjectStatus.active => 'Active',
    ProjectStatus.paused => 'Paused',
    ProjectStatus.shipped => 'Shipped',
    ProjectStatus.archived => 'Archived',
  };
}

String _taskStatusLabel(TaskStatus status) {
  return switch (status) {
    TaskStatus.notStarted => 'NOT STARTED',
    TaskStatus.inProgress => 'IN PROGRESS',
    TaskStatus.done => 'DONE',
    TaskStatus.stuck => 'STUCK',
  };
}
