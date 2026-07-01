import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/enums/opportunity_type.dart';
import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:ciaraos/widgets/opportunities/opportunity_pipeline_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OpportunityCreateEditScreen extends ConsumerStatefulWidget {
  const OpportunityCreateEditScreen({super.key, this.opportunityId});

  final String? opportunityId;

  bool get isEditMode => opportunityId != null;

  @override
  ConsumerState<OpportunityCreateEditScreen> createState() =>
      _OpportunityCreateEditScreenState();
}

class _OpportunityCreateEditScreenState
    extends ConsumerState<OpportunityCreateEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _organizationController;
  late final TextEditingController _fitNotesController;
  late final TextEditingController _linkController;
  late final TextEditingController _newDocumentController;

  OpportunityType? _selectedType;
  OpportunityStatus _selectedStatus = OpportunityStatus.researching;
  DateTime? _selectedDeadline;
  List<OpportunityDocument> _documents = [];
  int? _leadQuality;
  bool _isSaving = false;
  bool _titleError = false;
  bool _organizationError = false;
  bool _typeError = false;
  bool _linkError = false;
  bool _didPopulate = false;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _organizationController = TextEditingController();
    _fitNotesController = TextEditingController();
    _linkController = TextEditingController();
    _newDocumentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _fitNotesController.dispose();
    _linkController.dispose();
    _newDocumentController.dispose();
    super.dispose();
  }

  void _populateFromOpportunity(Opportunity opportunity) {
    _titleController.text = opportunity.title;
    _organizationController.text = opportunity.organization;
    _fitNotesController.text = opportunity.fitNotes ?? '';
    _linkController.text = opportunity.link ?? '';
    _selectedType = opportunity.type;
    _selectedStatus = opportunity.status;
    _selectedDeadline = opportunity.deadline;
    _documents = [...opportunity.documents];
    _leadQuality = opportunity.leadQuality;
    _createdAt = opportunity.createdAt;
  }

  bool _isValidUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
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

  void _addDocument() {
    final name = _newDocumentController.text.trim();
    if (name.isEmpty) {
      return;
    }

    setState(() {
      _documents = [
        ..._documents,
        OpportunityDocument(name: name, required: true, completed: false),
      ];
      _newDocumentController.clear();
    });
  }

  void _removeDocument(int index) {
    setState(() {
      _documents = [
        for (var i = 0; i < _documents.length; i++)
          if (i != index) _documents[i],
      ];
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final organization = _organizationController.text.trim();
    final link = _linkController.text.trim();
    final hasTitleError = title.isEmpty;
    final hasOrganizationError = organization.isEmpty;
    final hasTypeError = _selectedType == null;
    final hasLinkError = link.isNotEmpty && !_isValidUrl(link);

    if (hasTitleError ||
        hasOrganizationError ||
        hasTypeError ||
        hasLinkError) {
      setState(() {
        _titleError = hasTitleError;
        _organizationError = hasOrganizationError;
        _typeError = hasTypeError;
        _linkError = hasLinkError;
      });
      return;
    }

    setState(() {
      _titleError = false;
      _organizationError = false;
      _typeError = false;
      _linkError = false;
      _isSaving = true;
    });

    final repository = ref.read(opportunityRepositoryProvider);
    final now = DateTime.now();
    final fitNotes = _fitNotesController.text.trim();
    final documentsReady = _documents.where((doc) => doc.completed).length;

    try {
      if (widget.isEditMode) {
        final opportunity = Opportunity(
          id: int.parse(widget.opportunityId!),
          title: title,
          organization: organization,
          type: _selectedType!,
          status: _selectedStatus,
          deadline: _selectedDeadline,
          fitNotes: fitNotes.isEmpty ? null : fitNotes,
          documents: _documents,
          documentsTotal: _documents.length,
          documentsReady: documentsReady,
          link: link.isEmpty ? null : link,
          leadQuality: _leadQuality,
          createdAt: _createdAt ?? now,
          updatedAt: now,
        );
        await repository.update(opportunity.toCompanion());
      } else {
        final opportunity = Opportunity(
          id: 0,
          title: title,
          organization: organization,
          type: _selectedType!,
          status: _selectedStatus,
          deadline: _selectedDeadline,
          fitNotes: fitNotes.isEmpty ? null : fitNotes,
          documents: _documents,
          documentsTotal: _documents.length,
          documentsReady: documentsReady,
          link: link.isEmpty ? null : link,
          createdAt: now,
          updatedAt: now,
        );
        await repository.insert(opportunity.toCompanion(forInsert: true));
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

  Future<void> _deleteOpportunity() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete this opportunity?',
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

    await ref
        .read(opportunityRepositoryProvider)
        .delete(int.parse(widget.opportunityId!));
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isEditMode) {
      final opportunityId = int.parse(widget.opportunityId!);
      final opportunityAsync = ref.watch(opportunityByIdProvider(opportunityId));

      ref.listen(opportunityByIdProvider(opportunityId), (previous, next) {
        next.whenData((opportunity) {
          if (opportunity != null && !_didPopulate && mounted) {
            setState(() {
              _didPopulate = true;
              _populateFromOpportunity(opportunity);
            });
          }
        });
      });

      if (opportunityAsync.isLoading && !_didPopulate) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (opportunityAsync.hasError || opportunityAsync.value == null) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Center(
            child: Text(
              'Could not load opportunity.',
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
            _OpportunityFormHeader(
              title: widget.isEditMode ? 'Edit Opportunity' : 'New Opportunity',
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
                  const _FormFieldLabel(text: 'ROLE / PROGRAM TITLE'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _titleController,
                    maxLines: 1,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: _fieldDecoration(
                      context,
                      hint: 'e.g. Software Engineer, MSc Computer Science',
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
                  const _FormFieldLabel(text: 'ORGANIZATION'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _organizationController,
                    maxLines: 1,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: _fieldDecoration(
                      context,
                      hint: 'Company, university, or institution name',
                    ),
                    onChanged: (_) {
                      if (_organizationError) {
                        setState(() => _organizationError = false);
                      }
                    },
                  ),
                  if (_organizationError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Organization is required',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'TYPE'),
                  const SizedBox(height: AppSpacing.sm),
                  _OpportunityTypeChipRow(
                    selected: _selectedType,
                    onSelected: (type) => setState(() {
                      _selectedType = type;
                      _typeError = false;
                    }),
                  ),
                  if (_typeError) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Select a type',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'PIPELINE STAGE'),
                  const SizedBox(height: AppSpacing.sm),
                  OpportunityPipelineStepper(
                    currentStatus: _selectedStatus,
                    showHeader: false,
                    onStageSelected: (status) =>
                        setState(() => _selectedStatus = status),
                  ),
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
                  const _FormFieldLabel(text: 'REQUIRED DOCUMENTS'),
                  const SizedBox(height: AppSpacing.sm),
                  _DocumentsSection(
                    documents: _documents,
                    newDocumentController: _newDocumentController,
                    onAdd: _addDocument,
                    onRemove: _removeDocument,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'FIT NOTES'),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _fitNotesController,
                    minLines: 3,
                    maxLines: null,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: _fieldDecoration(
                      context,
                      hint: 'Why does this opportunity fit your goals?',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FormFieldLabel(text: 'APPLICATION LINK'),
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
                      hint: 'https://...',
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
                  if (widget.isEditMode) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _deleteOpportunity,
                        child: Text(
                          'DELETE OPPORTUNITY',
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

class _OpportunityFormHeader extends StatelessWidget {
  const _OpportunityFormHeader({
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
        fontFamily: AppTypography.monospace.fontFamily,
      ),
    );
  }
}

class _OpportunityTypeChipRow extends StatelessWidget {
  const _OpportunityTypeChipRow({
    required this.selected,
    required this.onSelected,
  });

  final OpportunityType? selected;
  final ValueChanged<OpportunityType> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.brightness == Brightness.dark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final type in OpportunityType.values)
          _OpportunityTypeChip(
            label: opportunityTypeTagLabel(type),
            isSelected: type == selected,
            primary: primary,
            onTap: () => onSelected(type),
          ),
      ],
    );
  }
}

class _OpportunityTypeChip extends StatelessWidget {
  const _OpportunityTypeChip({
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: primary),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? colorScheme.onPrimary : primary,
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

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    required this.documents,
    required this.newDocumentController,
    required this.onAdd,
    required this.onRemove,
  });

  final List<OpportunityDocument> documents;
  final TextEditingController newDocumentController;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: newDocumentController,
                maxLines: 1,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: _fieldDecoration(
                  context,
                  hint: 'Document name',
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onAdd,
              child: Text(
                'ADD',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        if (documents.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No documents added',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        for (var i = 0; i < documents.length; i++) ...[
          const SizedBox(height: AppSpacing.sm),
          _DocumentRow(
            name: documents[i].name,
            onRemove: () => onRemove(i),
          ),
        ],
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.name,
    required this.onRemove,
  });

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: AppSpacing.xl,
              minHeight: AppSpacing.xl,
            ),
          ),
        ],
      ),
    );
  }
}
