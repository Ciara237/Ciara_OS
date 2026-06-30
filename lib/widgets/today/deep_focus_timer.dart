import 'dart:async';

import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class DeepFocusTimer extends StatefulWidget {
  const DeepFocusTimer({super.key});

  @override
  State<DeepFocusTimer> createState() => _DeepFocusTimerState();
}

class _DeepFocusTimerState extends State<DeepFocusTimer> {
  static const int _totalSeconds = 45 * 60;

  bool _expanded = false;
  bool _running = false;
  int _remainingSeconds = _totalSeconds;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  void _toggleRunning() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }

    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _running = false;
        });
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress => _remainingSeconds / _totalSeconds;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _expanded ? null : _toggleExpanded,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _expanded
                ? _ExpandedTimer(
                    key: const ValueKey('expanded'),
                    formattedTime: _formattedTime,
                    progress: _progress,
                    running: _running,
                    onCollapse: _toggleExpanded,
                    onResume: _toggleRunning,
                    onReset: _reset,
                  )
                : _CollapsedTimer(
                    key: const ValueKey('collapsed'),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedTimer extends StatelessWidget {
  const _CollapsedTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '⚡ DEEP FOCUS',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'TAP TO EXPAND',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedTimer extends StatelessWidget {
  const _ExpandedTimer({
    super.key,
    required this.formattedTime,
    required this.progress,
    required this.running,
    required this.onCollapse,
    required this.onResume,
    required this.onReset,
  });

  final String formattedTime;
  final double progress;
  final bool running;
  final VoidCallback onCollapse;
  final VoidCallback onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚡ DEEP FOCUS',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: onCollapse,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            formattedTime,
            textAlign: TextAlign.center,
            style: AppTypography.monospace.copyWith(
              color: colorScheme.onSurface,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              height: 56 / 48,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress,
            minHeight: AppSpacing.xs,
            backgroundColor: colorScheme.surfaceContainerLow,
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onResume,
                  child: Text(
                    running ? 'PAUSE' : 'RESUME',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReset,
                  child: Text(
                    'RESET',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
