import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Card-specific status dot colors — not domain colors.
abstract final class _ProjectStatusColors {
  // Intentionally matches Opportunities domain color (#10B981) — do not change.
  static const Color active = Color(0xFF10B981);
  static const Color paused = Color(0xFFF59E0B);
  static const Color shipped = Color(0xFF3B82F6);
  static const Color archived = Color(0xFF64748B);
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  final Project project;
  final VoidCallback? onTap;

  static Color _statusDotColor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.active => _ProjectStatusColors.active,
      ProjectStatus.paused => _ProjectStatusColors.paused,
      ProjectStatus.shipped => _ProjectStatusColors.shipped,
      ProjectStatus.archived => _ProjectStatusColors.archived,
    };
  }

  static String _statusLabel(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.active => 'Active',
      ProjectStatus.paused => 'Paused',
      ProjectStatus.shipped => 'Shipped',
      ProjectStatus.archived => 'Archived',
    };
  }

  Future<void> _openExternalLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(project.domain);
    final hasNextAction = project.nextAction != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 2,
                  width: double.infinity,
                  color: domainColor,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
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
                            style: AppTypography.labelSmall.copyWith(
                              color: domainColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: AppTypography.headingMedium.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (project.externalLink != null)
                            IconButton(
                              icon: Icon(
                                Icons.open_in_new,
                                color: colorScheme.onSurfaceVariant,
                                size: AppSpacing.lg,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: AppSpacing.xl,
                                minHeight: AppSpacing.xl,
                              ),
                              onPressed: () =>
                                  _openExternalLink(project.externalLink!),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _statusDotColor(project.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _statusLabel(project.status),
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Divider(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                        height: 1,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'NEXT ACTION',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        project.nextAction ?? 'No next action set.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: hasNextAction
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontStyle: hasNextAction
                              ? FontStyle.normal
                              : FontStyle.italic,
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
    );
  }
}
