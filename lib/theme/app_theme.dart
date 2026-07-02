import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Domain accent colors exposed via [ThemeExtension] so widgets can call
/// `context.domainColor(Domain.engineering)` and automatically get the
/// correct dark/light shade without importing [AppColors] directly.
@immutable
class CiaraDomainColors extends ThemeExtension<CiaraDomainColors> {
  const CiaraDomainColors({required this.colors});

  final Map<Domain, Color> colors;

  Color operator [](Domain domain) => colors[domain]!;

  Color forDomain(Domain domain) => colors[domain]!;

  @override
  CiaraDomainColors copyWith({Map<Domain, Color>? colors}) {
    return CiaraDomainColors(colors: colors ?? this.colors);
  }

  @override
  CiaraDomainColors lerp(CiaraDomainColors? other, double t) {
    if (other == null) {
      return this;
    }

    return CiaraDomainColors(
      colors: {
        for (final domain in Domain.values)
          domain: Color.lerp(colors[domain], other.colors[domain], t)!,
      },
    );
  }
}

extension CiaraThemeContext on BuildContext {
  CiaraDomainColors get domainColors =>
      Theme.of(this).extension<CiaraDomainColors>()!;

  Color domainColor(Domain domain) => domainColors.forDomain(domain);
}

abstract final class AppTheme {
  static ThemeData get darkTheme => _buildTheme(
        colorScheme: AppColors.darkScheme,
        domainColors: AppColors.domainColors,
      );

  static ThemeData get lightTheme => _buildTheme(
        colorScheme: AppColors.lightScheme,
        domainColors: AppColors.domainColorsLight,
      );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Map<Domain, Color> domainColors,
  }) {
    final textTheme = AppTypography.textTheme.apply(
      decoration: TextDecoration.none,
    ).copyWith(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: colorScheme.onSurface,
        decoration: TextDecoration.none,
      ),
      headlineLarge: AppTypography.headingLarge.copyWith(
        color: colorScheme.onSurface,
        decoration: TextDecoration.none,
      ),
      headlineMedium: AppTypography.headingMedium.copyWith(
        color: colorScheme.onSurface,
        decoration: TextDecoration.none,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: colorScheme.onSurface,
        decoration: TextDecoration.none,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: colorScheme.onSurface,
        decoration: TextDecoration.none,
      ),
      labelLarge: AppTypography.labelLarge.copyWith(
        color: colorScheme.onSurfaceVariant,
        decoration: TextDecoration.none,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: colorScheme.onSurfaceVariant,
        decoration: TextDecoration.none,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppSpacing.appBarHeight,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: AppTypography.headingLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        labelStyle: AppTypography.labelLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: colorScheme.outline,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        labelStyle: AppTypography.labelLarge,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.bottomNavHeight,
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      extensions: [
        CiaraDomainColors(colors: domainColors),
      ],
    );
  }
}
