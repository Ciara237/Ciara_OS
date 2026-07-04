import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

const securityRed = Color(0xFFEF4444);

/// Terminal-style empty state when a security integration is unavailable.
class SecurityApiTerminalEmptyState extends StatelessWidget {
  const SecurityApiTerminalEmptyState({
    super.key,
    required this.scriptName,
    required this.initMessage,
    required this.errorMessage,
    required this.helpMessage,
    this.onLogManual,
    this.onSync,
  });

  final String scriptName;
  final String initMessage;
  final String errorMessage;
  final String helpMessage;
  final VoidCallback? onLogManual;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                _TerminalDot(color: colorScheme.error.withValues(alpha: 0.5)),
                const SizedBox(width: AppSpacing.xs),
                _TerminalDot(color: colorScheme.tertiary.withValues(alpha: 0.5)),
                const SizedBox(width: AppSpacing.xs),
                _TerminalDot(color: colorScheme.primary.withValues(alpha: 0.5)),
                const Spacer(),
                Text(
                  scriptName,
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TerminalLine(prefix: r'$', text: initMessage),
                const SizedBox(height: AppSpacing.md),
                _TerminalLine(
                  prefix: '!',
                  text: errorMessage,
                  prefixColor: colorScheme.error,
                  textColor: colorScheme.error,
                  bold: true,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    helpMessage,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
                if (onLogManual != null || onSync != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (onLogManual != null)
                        FilledButton.icon(
                          onPressed: onLogManual,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Log Manually'),
                        ),
                      if (onSync != null)
                        OutlinedButton.icon(
                          onPressed: onSync,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry Connection'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityLockedSection extends StatelessWidget {
  const SecurityLockedSection({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colorScheme.outline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalDot extends StatelessWidget {
  const _TerminalDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _TerminalLine extends StatelessWidget {
  const _TerminalLine({
    required this.prefix,
    required this.text,
    this.prefixColor,
    this.textColor,
    this.bold = false,
  });

  final String prefix;
  final String text;
  final Color? prefixColor;
  final Color? textColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prefix,
          style: AppTypography.labelSmall.copyWith(
            color: prefixColor ?? colorScheme.primary.withValues(alpha: 0.5),
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: textColor ?? colorScheme.onSurface,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
