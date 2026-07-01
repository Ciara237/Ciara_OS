import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Bumped when persisted daily focus / streak stats change.
final dailyStatsRevisionProvider = StateProvider<int>((ref) => 0);

void bumpDailyStatsRevision(WidgetRef ref) {
  ref.read(dailyStatsRevisionProvider.notifier).state++;
}
