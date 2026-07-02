import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/services/github_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final githubServiceProvider = Provider<GitHubService>((ref) {
  return GitHubService();
});

final githubActivityProvider = NotifierProvider<GitHubActivityNotifier,
    AsyncValue<GitHubActivity?>>(
  GitHubActivityNotifier.new,
);

class GitHubActivityNotifier extends Notifier<AsyncValue<GitHubActivity?>> {
  @override
  AsyncValue<GitHubActivity?> build() {
    return const AsyncValue.data(null);
  }

  DateTime? _lastSynced;

  Future<void> sync() async {
    state = const AsyncValue.loading();
    final username = ref.read(profileProvider).githubUsername;
    try {
      final activity = await ref
          .read(githubServiceProvider)
          .fetchActivity(username: username);
      _lastSynced = DateTime.now();
      state = AsyncValue.data(activity);
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
