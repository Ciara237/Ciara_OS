import 'package:ciaraos/models/security_activity.dart';
import 'package:ciaraos/services/security_cache.dart';
import 'package:ciaraos/services/security_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

final securityApiProbeProvider = FutureProvider<SecurityApiProbe>((ref) async {
  return ref.read(securityServiceProvider).probeEndpoints();
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
    Future.microtask(_restoreFromCache);
    return const AsyncValue.data(null);
  }

  DateTime? _lastSynced;
  bool _cacheLoaded = false;

  Future<void> _restoreFromCache() async {
    if (_cacheLoaded) {
      return;
    }
    _cacheLoaded = true;

    final cached = await SecurityCache.loadHackTheBox();
    if (cached == null) {
      return;
    }

    _lastSynced = cached.syncedAt;
    if (state.value == null) {
      state = AsyncValue.data(cached);
    }
  }

  Future<void> sync() async {
    final previous = state.value;
    if (previous == null) {
      state = const AsyncValue.loading();
    }

    try {
      final profile =
          await ref.read(securityServiceProvider).fetchHackTheBox();
      if (profile != null) {
        _lastSynced = DateTime.now();
        state = AsyncValue.data(profile);
        return;
      }
      if (previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
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
    Future.microtask(_restoreFromCache);
    return const AsyncValue.data(null);
  }

  DateTime? _lastSynced;
  bool _cacheLoaded = false;

  Future<void> _restoreFromCache() async {
    if (_cacheLoaded) {
      return;
    }
    _cacheLoaded = true;

    final cached = await SecurityCache.loadHackerOne();
    if (cached == null) {
      return;
    }

    _lastSynced = cached.syncedAt;
    if (state.value == null) {
      state = AsyncValue.data(cached);
    }
  }

  Future<void> sync() async {
    final previous = state.value;
    if (previous == null) {
      state = const AsyncValue.loading();
    }

    try {
      final profile =
          await ref.read(securityServiceProvider).fetchHackerOne();
      if (profile != null) {
        _lastSynced = DateTime.now();
        state = AsyncValue.data(profile);
        return;
      }
      if (previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncValue.data(previous);
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
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
