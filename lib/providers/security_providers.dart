import 'package:ciaraos/models/security_activity.dart';
import 'package:ciaraos/services/security_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

final activeSecurityTabProvider = StateProvider<int>((ref) => 0);

final hackTheBoxProvider =
    NotifierProvider<HackTheBoxNotifier, AsyncValue<HackTheBoxProfile?>>(
  HackTheBoxNotifier.new,
);

final hackerOneProvider =
    NotifierProvider<HackerOneNotifier, AsyncValue<HackerOneProfile?>>(
  HackerOneNotifier.new,
);

class HackTheBoxNotifier extends Notifier<AsyncValue<HackTheBoxProfile?>> {
  @override
  AsyncValue<HackTheBoxProfile?> build() {
    return const AsyncValue.data(null);
  }

  DateTime? _lastSynced;

  Future<void> sync() async {
    state = const AsyncValue.loading();
    try {
      final profile =
          await ref.read(securityServiceProvider).fetchHackTheBox();
      _lastSynced = DateTime.now();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  bool get shouldAutoSync {
    if (_lastSynced == null) {
      return true;
    }
    return DateTime.now().difference(_lastSynced!) >
        const Duration(hours: 2);
  }
}

class HackerOneNotifier extends Notifier<AsyncValue<HackerOneProfile?>> {
  @override
  AsyncValue<HackerOneProfile?> build() {
    return const AsyncValue.data(null);
  }

  DateTime? _lastSynced;

  Future<void> sync() async {
    state = const AsyncValue.loading();
    try {
      final profile =
          await ref.read(securityServiceProvider).fetchHackerOne();
      _lastSynced = DateTime.now();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  bool get shouldAutoSync {
    if (_lastSynced == null) {
      return true;
    }
    return DateTime.now().difference(_lastSynced!) >
        const Duration(hours: 2);
  }
}
