import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/resource.dart';
import 'package:ciaraos/providers/resource_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAddResourceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => const AddResourceSheet(),
  );
}

class AddResourceSheet extends ConsumerStatefulWidget {
  const AddResourceSheet({super.key});

  @override
  ConsumerState<AddResourceSheet> createState() => _AddResourceSheetState();
}

class _AddResourceSheetState extends ConsumerState<AddResourceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();

  Domain _domain = Domain.engineering;
  ResourceType _type = ResourceType.course;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onUrlChanged(String value) {
    const driveHosts = [
      'drive.google.com',
      'docs.google.com',
      'sheets.google.com',
      'slides.google.com',
    ];
    final isDrive = driveHosts.any((host) => value.contains(host));
    if (isDrive && _type != ResourceType.drive) {
      setState(() => _type = ResourceType.drive);
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) {
      return 'Enter a valid URL';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(resourceRepositoryProvider);
    final now = DateTime.now();

    try {
      final resource = Resource(
        id: 0,
        title: _titleController.text.trim(),
        url: _urlController.text.trim(),
        domain: _domain,
        type: _type,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await repo.insert(resource.toCompanion(forInsert: true));

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ADD RESOURCE',
                        style: AppTypography.labelLarge.copyWith(
                          color: colorScheme.onSurface,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'URL',
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: _onUrlChanged,
                        validator: _validateUrl,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'DOMAIN',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: Domain.values.map((domain) {
                          final selected = _domain == domain;
                          final domainColor = AppColors.domainColors[domain]!;
                          return FilterChip(
                            label: Text(domainShortLabel(domain)),
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
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'TYPE',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: ResourceType.values.map((type) {
                          final selected = _type == type;
                          final typeColor = resourceTypeColor(
                            type,
                            colorScheme,
                          );
                          return FilterChip(
                            label: Text(resourceTypeLabel(type)),
                            selected: selected,
                            onSelected: (_) => setState(() => _type = type),
                            showCheckmark: false,
                            avatar: Icon(
                              resourceTypeIcon(type),
                              size: 16,
                              color: selected
                                  ? typeColor
                                  : colorScheme.onSurfaceVariant,
                            ),
                            labelStyle: AppTypography.labelSmall.copyWith(
                              color: selected
                                  ? typeColor
                                  : colorScheme.onSurfaceVariant,
                            ),
                            selectedColor: typeColor.withValues(alpha: 0.1),
                            side: BorderSide(
                              color: selected
                                  ? typeColor
                                  : colorScheme.outlineVariant,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'SAVE RESOURCE',
                          style: AppTypography.labelLarge.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
