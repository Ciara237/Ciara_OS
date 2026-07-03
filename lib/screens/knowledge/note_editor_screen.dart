import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/note.dart';
import 'package:ciaraos/providers/note_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});

  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Domain _domain = Domain.engineering;
  bool _loaded = false;
  bool _saving = false;
  Note? _existing;

  bool get _isEditing => widget.noteId != null;

  bool get _isReadOnly => _existing?.isNotionSynced ?? false;

  Future<void> _openInNotion() async {
    final url = _existing?.notionUrl;
    if (url == null || url.isEmpty) {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  int? get _parsedId {
    final id = widget.noteId;
    if (id == null) {
      return null;
    }
    return int.tryParse(id);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final id = _parsedId;
    if (id == null) {
      setState(() => _loaded = true);
      return;
    }

    final note = await ref.read(noteRepositoryProvider).getById(id);
    if (!mounted) {
      return;
    }

    if (note != null) {
      _existing = note;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _domain = note.domain;
    }
    setState(() => _loaded = true);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadNote);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required.')),
      );
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(noteRepositoryProvider);
    final now = DateTime.now();
    final content = _contentController.text;
    final words = countWords(content);

    try {
      if (_isEditing && _existing != null) {
        final updated = _existing!.copyWith(
          title: title,
          content: content,
          domain: _domain,
          wordCount: words,
          updatedAt: now,
        );
        await repo.update(updated.toCompanion());
      } else {
        final note = Note(
          id: 0,
          title: title,
          content: content,
          domain: _domain,
          wordCount: words,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insert(note.toCompanion(forInsert: true));
      }

      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final existing = _existing;
    if (existing == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text('Remove "${existing.title}"?'),
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

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(noteRepositoryProvider).delete(existing.id);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_loaded) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isEditing && _existing == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Text(
            'Note not found.',
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final words = countWords(_contentController.text);
    final isReadOnly = _isReadOnly;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          Container(
            height: AppSpacing.appBarHeight,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                ),
                Expanded(
                  child: Text(
                    isReadOnly
                        ? 'NOTION NOTE'
                        : (_isEditing ? 'EDIT NOTE' : 'NEW NOTE'),
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onSurface,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (!isReadOnly)
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: Text(
                      'SAVE',
                      style: AppTypography.labelLarge.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isReadOnly)
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: Domain.values.map((domain) {
                        final selected = _domain == domain;
                        final domainColor = AppColors.domainColors[domain]!;
                        return FilterChip(
                          label: Text(domainLabel(domain)),
                          selected: selected,
                          onSelected: (_) => setState(() => _domain = domain),
                          selectedColor: domainColor.withValues(alpha: 0.15),
                          checkmarkColor: domainColor,
                          labelStyle: AppTypography.labelSmall.copyWith(
                            color: selected
                                ? domainColor
                                : colorScheme.onSurfaceVariant,
                          ),
                          side: BorderSide(
                            color: selected
                                ? domainColor
                                : colorScheme.outlineVariant,
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          'NOTION',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _titleController,
                    readOnly: isReadOnly,
                    style: AppTypography.headingMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Note title...',
                      border: InputBorder.none,
                      hintStyle: AppTypography.headingMedium.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      readOnly: isReadOnly,
                      onChanged: isReadOnly ? null : (_) => setState(() {}),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: AppTypography.bodyLarge.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        border: InputBorder.none,
                        hintStyle: AppTypography.bodyLarge.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isReadOnly) ...[
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: _openInNotion,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Synced from Notion · Open in Notion →'),
                    ),
                  ] else if (_isEditing) ...[
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                      ),
                      child: const Text('DELETE NOTE'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '$words ${words == 1 ? 'word' : 'words'}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 1,
                  height: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  domainLabel(_domain),
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.primary,
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
