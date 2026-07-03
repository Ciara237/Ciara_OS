import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/resource.dart';
import 'package:ciaraos/providers/resource_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/knowledge/add_resource_sheet.dart';
import 'package:ciaraos/widgets/navigation/sidebar_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredResourcesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SidebarScreenScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          _ScreenIntro(
            onAdd: () => showAddResourceSheet(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SearchField(
            onChanged: (value) =>
                ref.read(resourceSearchQueryProvider.notifier).state = value,
          ),
          const SizedBox(height: AppSpacing.md),
          _DomainFilterRow(
            selected: ref.watch(resourceDomainFilterProvider),
            onSelected: (domain) =>
                ref.read(resourceDomainFilterProvider.notifier).state = domain,
          ),
          const SizedBox(height: AppSpacing.sm),
          _TypeFilterRow(
            selected: ref.watch(resourceTypeFilterProvider),
            onSelected: (type) =>
                ref.read(resourceTypeFilterProvider.notifier).state = type,
          ),
          const SizedBox(height: AppSpacing.lg),
          filteredAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              'Could not load resources.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            data: (resources) {
              if (resources.isEmpty) {
                return const _EmptyState();
              }
              return Column(
                children: resources
                    .map(
                      (resource) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ResourceCard(resource: resource),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScreenIntro extends StatelessWidget {
  const _ScreenIntro({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KNOWLEDGE',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resources',
                    style: AppTypography.headingLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Curated links and references for deep focus sessions.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'ADD RESOURCE',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search resources...',
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class _DomainFilterRow extends StatelessWidget {
  const _DomainFilterRow({
    required this.selected,
    required this.onSelected,
  });

  final Domain? selected;
  final ValueChanged<Domain?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All domains',
            selected: selected == null,
            onSelected: () => onSelected(null),
            colorScheme: colorScheme,
          ),
          ...Domain.values.map(
            (domain) => _FilterChip(
              label: domainShortLabel(domain),
              selected: selected == domain,
              onSelected: () => onSelected(domain),
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeFilterRow extends StatelessWidget {
  const _TypeFilterRow({
    required this.selected,
    required this.onSelected,
  });

  final ResourceType? selected;
  final ValueChanged<ResourceType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All types',
            selected: selected == null,
            onSelected: () => onSelected(null),
            colorScheme: colorScheme,
          ),
          ...ResourceType.values.map(
            (type) => _FilterChip(
              label: resourceTypeLabel(type),
              selected: selected == type,
              onSelected: () => onSelected(type),
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.colorScheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        labelStyle: AppTypography.labelSmall.copyWith(
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          fontSize: 11,
        ),
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
    );
  }
}

class _ResourceCard extends ConsumerWidget {
  const _ResourceCard({required this.resource});

  final Resource resource;

  Future<void> _openUrl() async {
    final uri = Uri.tryParse(resource.url);
    if (uri == null || !await canLaunchUrl(uri)) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete resource?'),
        content: Text('Remove "${resource.title}"?'),
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

    if (confirmed == true) {
      await ref.read(resourceRepositoryProvider).delete(resource.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = AppColors.domainColors[resource.domain]!;
    final typeColor = resourceTypeColor(resource.type, colorScheme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openUrl,
        onLongPress: () => _confirmDelete(context, ref),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(AppSpacing.radiusMd),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                      right: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(
                                color: typeColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  resourceTypeIcon(resource.type),
                                  size: 12,
                                  color: typeColor,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  resourceTypeLabel(resource.type),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: typeColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _openUrl,
                            icon: Icon(
                              Icons.open_in_new,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        resource.title,
                        style: AppTypography.headingMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        resource.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: domainColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            domainLabel(resource.domain),
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'ADDED ${DateFormat('MMM d').format(resource.createdAt).toUpperCase()}',
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.link_off_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No resources saved...',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add courses, docs, and tools you want one tap away during focus.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
