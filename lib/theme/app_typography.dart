import 'package:ciaraos/theme/app_responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens from Stitch `fontSize` config (Inter + JetBrains Mono).
/// All methods have responsive variants that scale on mobile devices.
abstract final class AppTypography {
  /// display-lg — 48 / 56, w700, -0.02em
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
      );

  /// Responsive displayLarge - scales on mobile
  static TextStyle displayLargeResponsive(BuildContext context) {
    final scale = AppResponsive.pageTitleScale(context);
    return displayLarge.copyWith(fontSize: 48 * scale);
  }

  /// headline-md — 24 / 32, w600, -0.01em
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
      );

  /// Responsive headingLarge - scales on mobile
  static TextStyle headingLargeResponsive(BuildContext context) {
    final scale = AppResponsive.sectionHeadingScale(context);
    return headingLarge.copyWith(fontSize: 24 * scale);
  }

  /// headline-md-mobile — 20 / 28, w600
  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      );

  /// Responsive headingMedium - scales on mobile
  static TextStyle headingMediumResponsive(BuildContext context) {
    final scale = AppResponsive.cardTitleScale(context);
    return headingMedium.copyWith(fontSize: 20 * scale);
  }

  /// body-base — 16 / 24, w400
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  /// Responsive bodyLarge - scales on mobile
  static TextStyle bodyLargeResponsive(BuildContext context) {
    final scale = AppResponsive.bodyTextScale(context);
    return bodyLarge.copyWith(fontSize: 16 * scale);
  }

  /// body-sm — 14 / 20, w400
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      );

  /// Responsive bodyMedium - scales on mobile
  static TextStyle bodyMediumResponsive(BuildContext context) {
    final scale = AppResponsive.bodyTextScale(context);
    return bodyMedium.copyWith(fontSize: 14 * scale);
  }

  /// code-label — 12 / 16, w500, 0.05em (form labels, chips)
  static TextStyle get labelLarge => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
      );

  /// Responsive labelLarge - scales on mobile
  static TextStyle labelLargeResponsive(BuildContext context) {
    final scale = AppResponsive.monospaceLabelScale(context);
    return labelLarge.copyWith(fontSize: 12 * scale);
  }

  /// Nav / micro labels — 10 / tight, w500
  static TextStyle get labelSmall => GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.05 * 10,
      );

  /// Responsive labelSmall - scales on mobile
  static TextStyle labelSmallResponsive(BuildContext context) {
    final scale = AppResponsive.captionScale(context);
    return labelSmall.copyWith(fontSize: 10 * scale);
  }

  /// Terminal-style metadata (alias of code-label)
  static TextStyle get monospace => labelLarge;

  /// Responsive monospace - scales on mobile
  static TextStyle monospaceResponsive(BuildContext context) {
    return labelLargeResponsive(context);
  }

  /// Large statistic text for primary metrics (streaks, focus time, etc.)
  static TextStyle get statLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
      );

  /// Responsive statLarge - scales on mobile
  static TextStyle statLargeResponsive(BuildContext context) {
    final scale = AppResponsive.primaryStatScale(context);
    return statLarge.copyWith(fontSize: 28 * scale);
  }

  /// Medium statistic text
  static TextStyle get statMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      );

  /// Responsive statMedium - scales on mobile
  static TextStyle statMediumResponsive(BuildContext context) {
    final scale = AppResponsive.primaryStatScale(context);
    return statMedium.copyWith(fontSize: 20 * scale);
  }

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelLarge: labelLarge,
        labelSmall: labelSmall,
      );
}