import 'package:flutter/material.dart';

/// Responsive sizing utility for mobile typography and spacing.
/// All values are derived from screen width to support:
/// - Small Phone (< 360dp)
/// - Large Phone (360-720dp)
/// - Tablet/Desktop (>= 720dp)
///
/// Desktop behavior remains unchanged.
abstract final class AppResponsive {
  static const double _phoneBreakpoint = 600.0;
  static const double _smallPhoneBreakpoint = 360.0;

  /// Returns true if the screen is a phone (width < 600dp)
  static bool isPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < _phoneBreakpoint;
  }

  /// Returns true if the screen is a small phone (width < 360dp)
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < _smallPhoneBreakpoint;
  }

  /// Returns true if the screen is a tablet or desktop (width >= 600dp)
  static bool isTabletOrDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= _phoneBreakpoint;
  }

  // MARK: - Typography Scale Multipliers

  /// Scale factor for page titles (displayLarge)
  static double pageTitleScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.0;
    if (isPhone(context)) return 1.1;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for section headings (headingLarge)
  static double sectionHeadingScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.0;
    if (isPhone(context)) return 1.1;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for card titles (headingMedium)
  static double cardTitleScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.05;
    if (isPhone(context)) return 1.1;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for primary statistics
  static double primaryStatScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.15;
    if (isPhone(context)) return 1.25;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for body text
  static double bodyTextScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.15;
    if (isPhone(context)) return 1.2;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for captions (labelSmall)
  static double captionScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.15;
    if (isPhone(context)) return 1.2;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for monospaced labels (labelLarge)
  static double monospaceLabelScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.15;
    if (isPhone(context)) return 1.2;
    return 1.0; // Desktop unchanged
  }

  // MARK: - Spacing Multipliers

  /// Scale factor for vertical padding
  static double verticalPaddingScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.3;
    if (isPhone(context)) return 1.2;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for horizontal padding
  static double horizontalPaddingScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.15;
    if (isPhone(context)) return 1.1;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for section spacing
  static double sectionSpacingScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.4;
    if (isPhone(context)) return 1.3;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for card internal padding
  static double cardPaddingScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.3;
    if (isPhone(context)) return 1.25;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for widget spacing
  static double widgetSpacingScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.3;
    if (isPhone(context)) return 1.2;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for button height
  static double buttonHeightScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.3;
    if (isPhone(context)) return 1.25;
    return 1.0; // Desktop unchanged
  }

  /// Scale factor for icon sizes
  static double iconScale(BuildContext context) {
    if (isSmallPhone(context)) return 1.05;
    if (isPhone(context)) return 1.1;
    return 1.0; // Desktop unchanged
  }

  // MARK: - Computed Values

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