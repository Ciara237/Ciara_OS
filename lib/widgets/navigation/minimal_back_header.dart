import 'package:ciaraos/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Compact header with a single back control — no drawer avatar or app chrome.
class MinimalBackHeader extends StatelessWidget implements PreferredSizeWidget {
  const MinimalBackHeader({super.key, this.onBack, this.action});

  final VoidCallback? onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = AppSpacing.iconSize(context);
    final minTouchSize = AppSpacing.minIconButtonSize(context);

    return SafeArea(
      bottom: false,
      child: Container(
        height: appBarHeight,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: minTouchSize,
              height: minTouchSize,
              child: IconButton(
                onPressed: onBack ?? () => context.pop(),
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: iconSize),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: minTouchSize,
                  minHeight: minTouchSize,
                ),
                tooltip: 'Back',
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }

  static const double appBarHeight = 56.0;

  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);
}