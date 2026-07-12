import 'package:ciaraos/theme/app_responsive.dart';
import 'package:flutter/material.dart';

/// Spacing + radius tokens from Stitch tailwind config + DESIGN.md.
/// All methods have responsive variants that scale on mobile devices.
abstract final class AppSpacing {
  // Semantic spacing (maps to recurring HTML values)
  static const double xs = 4; // execution-gap
  static const double sm = 8; // execution-padding, p-2
  static const double md = 16; // p-4, gap-4, px-4
  static const double lg = 24; // review-gap, p-6, gap-6
  static const double xl = 32; // gap-8, py-8
  static const double xxl = 40; // review-padding, p-review-padding

  // Context-specific aliases used in Stitch screens
  static const double executionGap = xs;
  static const double executionPadding = sm;
  static const double reviewGap = lg;
  static const double reviewPadding = xxl;
  static const double containerMax = 1200;

  // Component dimensions
  static const double appBarHeight = 56; // h-14
  static const double bottomNavHeight = 64; // h-16
  static const double domainBarWidth = 6; // w-1.5
  static const double taskBorderWidth = 4; // border-l-4

  // Border radius — HTML tailwind + DESIGN.md rounded scale
  static const double radiusSm = 4; // DEFAULT / 0.25rem
  static const double radiusMd = 8; // lg / 0.5rem (standard buttons, inputs)
  static const double radiusLg = 16; // DESIGN.md lg / 1rem (review cards)
  static const double radiusFull = 9999;

  // MARK: - Responsive Spacing Methods

  /// Responsive vertical padding - increases on mobile
  static double verticalPadding(BuildContext context) {
    final scale = AppResponsive.verticalPaddingScale(context);
    return lg * scale;
  }

  /// Responsive horizontal padding - increases on mobile
  static double horizontalPadding(BuildContext context) {
    final scale = AppResponsive.horizontalPaddingScale(context);
    return md * scale;
  }

  /// Responsive section spacing - increases on mobile
  static double sectionSpacing(BuildContext context) {
    final scale = AppResponsive.sectionSpacingScale(context);
    return lg * scale;
  }

  /// Responsive card internal padding - increases on mobile
  static double cardPadding(BuildContext context) {
    final scale = AppResponsive.cardPaddingScale(context);
    return lg * scale;
  }

  /// Responsive widget spacing - increases on mobile
  static double widgetSpacing(BuildContext context) {
    final scale = AppResponsive.widgetSpacingScale(context);
    return sm * scale;
  }

  /// Responsive button height - increases on mobile
  static double buttonHeight(BuildContext context) {
    final scale = AppResponsive.buttonHeightScale(context);
    return 40 * scale;
  }

  /// Responsive icon size - increases on mobile
  static double iconSize(BuildContext context) {
    final scale = AppResponsive.iconScale(context);
    return 24 * scale;
  }

  /// Minimum touch target size (48dp)
  static double minTouchTarget(BuildContext context) {
    return 48.0;
  }

  /// Minimum icon button size (48dp)
  static double minIconButtonSize(BuildContext context) {
    return 48.0;
  }

  /// Minimum list tile height (48dp)
  static double minListTileHeight(BuildContext context) {
    return 48.0;
  }
}