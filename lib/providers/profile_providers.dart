import 'package:ciaraos/services/profile_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  const ProfileData({
    required this.displayName,
    required this.tagline,
    required this.isNameConfigured,
    required this.githubUsername,
  });

  final String displayName;
  final String tagline;
  final bool isNameConfigured;
  final String githubUsername;

  String get initials => avatarInitialsFromName(displayName);

  String get resolvedDisplayName =>
      displayName.trim().isEmpty ? 'Your Name' : displayName.trim();
}

class ProfileNotifier extends Notifier<ProfileData> {
  @override
  ProfileData build() {
    _loadFromPrefs();
    return const ProfileData(
      displayName: defaultProfileDisplayName,
      tagline: defaultProfileTagline,
      isNameConfigured: false,
      githubUsername: defaultGithubUsername,
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = ProfileData(
      displayName:
          prefs.getString(profileDisplayNamePreferenceKey) ??
              defaultProfileDisplayName,
      tagline:
          prefs.getString(profileTaglinePreferenceKey) ?? defaultProfileTagline,
      isNameConfigured:
          prefs.getBool(profileNameConfiguredPreferenceKey) ?? false,
      githubUsername:
          prefs.getString(githubUsernamePreferenceKey) ?? defaultGithubUsername,
    );
  }

  Future<void> reload() => _loadFromPrefs();

  Future<void> saveDisplayName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(profileDisplayNamePreferenceKey, trimmed);
    await prefs.setBool(profileNameConfiguredPreferenceKey, true);
    state = ProfileData(
      displayName: trimmed,
      tagline: state.tagline,
      isNameConfigured: true,
      githubUsername: state.githubUsername,
    );
  }

  Future<void> saveTagline(String value) async {
    final trimmed = value.trim();
    final next = trimmed.isEmpty ? defaultProfileTagline : trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(profileTaglinePreferenceKey, next);
    state = ProfileData(
      displayName: state.displayName,
      tagline: next,
      isNameConfigured: state.isNameConfigured,
      githubUsername: state.githubUsername,
    );
  }

  Future<void> saveGithubUsername(String value) async {
    final normalized = normalizeGithubUsername(value);
    if (!isValidGithubUsername(normalized)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(githubUsernamePreferenceKey, normalized);
    state = ProfileData(
      displayName: state.displayName,
      tagline: state.tagline,
      isNameConfigured: state.isNameConfigured,
      githubUsername: normalized,
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileData>(
  ProfileNotifier.new,
);
