enum PerformanceTrendDirection { up, down, flat, none }

/// Day-over-day change for a performance snapshot metric.
class PerformanceMetricTrend {
  const PerformanceMetricTrend({
    required this.direction,
    this.percentDelta,
    this.absoluteDelta,
    this.hoursDelta,
    this.unitLabel = 'd',
    this.displayMode = TrendDisplayMode.percent,
  });

  const PerformanceMetricTrend.none()
      : direction = PerformanceTrendDirection.none,
        percentDelta = null,
        absoluteDelta = null,
        hoursDelta = null,
        unitLabel = 'd',
        displayMode = TrendDisplayMode.percent;

  final PerformanceTrendDirection direction;
  final double? percentDelta;
  final int? absoluteDelta;
  final double? hoursDelta;
  final String unitLabel;
  final TrendDisplayMode displayMode;

  bool get isPositive => direction == PerformanceTrendDirection.up;
  bool get isNegative => direction == PerformanceTrendDirection.down;
  bool get isNeutral =>
      direction == PerformanceTrendDirection.flat ||
      direction == PerformanceTrendDirection.none;

  static PerformanceMetricTrend fromPercentDelta(double? delta) {
    if (delta == null) {
      return const PerformanceMetricTrend.none();
    }
    if (delta.abs() < 0.5) {
      return const PerformanceMetricTrend(
        direction: PerformanceTrendDirection.flat,
        percentDelta: 0,
        displayMode: TrendDisplayMode.percent,
      );
    }
    return PerformanceMetricTrend(
      direction:
          delta > 0 ? PerformanceTrendDirection.up : PerformanceTrendDirection.down,
      percentDelta: delta.abs(),
      displayMode: TrendDisplayMode.percent,
    );
  }

  static PerformanceMetricTrend fromAbsoluteDelta(
    int? delta, {
    String unit = 'd',
    TrendDisplayMode mode = TrendDisplayMode.absolute,
  }) {
    if (delta == null || delta == 0) {
      return delta == 0
          ? PerformanceMetricTrend(
              direction: PerformanceTrendDirection.flat,
              absoluteDelta: 0,
              unitLabel: unit,
              displayMode: mode,
            )
          : const PerformanceMetricTrend.none();
    }
    return PerformanceMetricTrend(
      direction:
          delta > 0 ? PerformanceTrendDirection.up : PerformanceTrendDirection.down,
      absoluteDelta: delta.abs(),
      unitLabel: unit,
      displayMode: mode,
    );
  }

  static PerformanceMetricTrend fromHoursDelta(double? deltaHours) {
    if (deltaHours == null) {
      return const PerformanceMetricTrend.none();
    }
    if (deltaHours.abs() < 0.05) {
      return const PerformanceMetricTrend(
        direction: PerformanceTrendDirection.flat,
        hoursDelta: 0,
        displayMode: TrendDisplayMode.hours,
      );
    }
    return PerformanceMetricTrend(
      direction: deltaHours > 0
          ? PerformanceTrendDirection.up
          : PerformanceTrendDirection.down,
      hoursDelta: deltaHours.abs(),
      displayMode: TrendDisplayMode.hours,
    );
  }

  String compactLabel() {
    return switch (displayMode) {
      TrendDisplayMode.stable => 'Stable',
      TrendDisplayMode.hours => _signedHours(),
      TrendDisplayMode.absolute => _signedAbsolute(),
      TrendDisplayMode.percent => _signedPercent(),
    };
  }

  String _signedPercent() {
    if (direction == PerformanceTrendDirection.none) {
      return '';
    }
    if (direction == PerformanceTrendDirection.flat) {
      return 'Stable';
    }
    final sign = direction == PerformanceTrendDirection.up ? '+' : '-';
    return '$sign${percentDelta?.round() ?? 0}%';
  }

  String _signedHours() {
    if (direction == PerformanceTrendDirection.none) {
      return '';
    }
    if (direction == PerformanceTrendDirection.flat) {
      return 'Stable';
    }
    final sign = direction == PerformanceTrendDirection.up ? '+' : '-';
    return '$sign${hoursDelta?.toStringAsFixed(1) ?? '0.0'}h';
  }

  String _signedAbsolute() {
    if (direction == PerformanceTrendDirection.none) {
      return '';
    }
    if (direction == PerformanceTrendDirection.flat) {
      if (unitLabel.isEmpty) {
        return 'Stable';
      }
      return unitLabel == 'd' ? 'Stable' : '0';
    }
    final sign = direction == PerformanceTrendDirection.up ? '+' : '-';
    if (unitLabel == 'd') {
      return '$sign${absoluteDelta}d';
    }
    return '$sign$absoluteDelta';
  }
}

enum TrendDisplayMode { percent, hours, absolute, stable }

double? relativePercentChange(num today, num yesterday) {
  if (yesterday == 0) {
    if (today == 0) {
      return null;
    }
    return 100;
  }
  return ((today - yesterday) / yesterday) * 100;
}

double? ratePointChange({
  required int numeratorToday,
  required int denominatorToday,
  required int numeratorYesterday,
  required int denominatorYesterday,
}) {
  if (denominatorToday == 0 && denominatorYesterday == 0) {
    return null;
  }

  final todayRate =
      denominatorToday == 0 ? 0.0 : numeratorToday / denominatorToday;
  final yesterdayRate = denominatorYesterday == 0
      ? 0.0
      : numeratorYesterday / denominatorYesterday;
  return (todayRate - yesterdayRate) * 100;
}

int streakAtEndOfYesterday({
  required int currentStreak,
  required String? lastActiveIso,
  required DateTime now,
}) {
  if (currentStreak <= 0 || lastActiveIso == null) {
    return 0;
  }

  final last = DateTime.parse(lastActiveIso);
  final lastDay = DateTime(last.year, last.month, last.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (lastDay.isBefore(yesterday)) {
    return 0;
  }
  if (lastDay == today) {
    return (currentStreak - 1).clamp(0, currentStreak);
  }
  if (lastDay == yesterday) {
    return currentStreak;
  }
  return currentStreak;
}
