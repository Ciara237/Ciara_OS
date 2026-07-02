import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens from Stitch `fontSize` config (Inter + JetBrains Mono).
abstract final class AppTypography {
  /// display-lg — 48 / 56, w700, -0.02em
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
      );

  /// headline-md — 24 / 32, w600, -0.01em
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
      );

  /// headline-md-mobile — 20 / 28, w600
  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
      );

  /// body-base — 16 / 24, w400
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  /// body-sm — 14 / 20, w400
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      );

  /// code-label — 12 / 16, w500, 0.05em (form labels, chips)
  static TextStyle get labelLarge => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
      );

  /// Nav / micro labels — 10 / tight, w500
  static TextStyle get labelSmall => GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.05 * 10,
      );

  /// Terminal-style metadata (alias of code-label)
  static TextStyle get monospace => labelLarge;

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
