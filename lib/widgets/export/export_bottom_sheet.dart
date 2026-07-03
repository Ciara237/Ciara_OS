import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Stitch `export_bottom_sheet_ciara_os_dark` — export format picker.
class ExportOption {
  const ExportOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onExport,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Future<void> Function() onExport;
}

Future<void> showCiaraExportSheet({
  required BuildContext context,
  String overline = 'EXPORT REPORT',
  required List<ExportOption> options,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => ExportBottomSheet(
      overline: overline,
      options: options,
    ),
  );
}

class ExportBottomSheet extends StatefulWidget {
  const ExportBottomSheet({
    super.key,
    required this.overline,
    required this.options,
  });

  final String overline;
  final List<ExportOption> options;

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  bool _isExporting = false;

  Future<void> _runExport(Future<void> Function() action) async {
    if (_isExporting) {
      return;
    }

    setState(() => _isExporting = true);
    try {
      await action();
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLow,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              Text(
                widget.overline,
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 3.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_isExporting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...widget.options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ExportOptionCard(
                      option: option,
                      onTap: () => _runExport(option.onExport),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.1),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _isExporting ? null : () => Navigator.pop(context),
                child: Text(
                  'CANCEL OPERATION',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 2,
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

class _ExportOptionCard extends StatelessWidget {
  const _ExportOptionCard({
    required this.option,
    required this.onTap,
  });

  final ExportOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.darkSurfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(option.icon, color: colorScheme.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: AppTypography.headingLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      option.subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
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
