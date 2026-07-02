class GitHubRepo {
  const GitHubRepo({
    required this.name,
    required this.description,
    required this.language,
    required this.stars,
    required this.forks,
    required this.updatedAt,
    required this.htmlUrl,
    required this.isFork,
  });

  final String name;
  final String? description;
  final String? language;
  final int stars;
  final int forks;
  final DateTime updatedAt;
  final String htmlUrl;
  final bool isFork;

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      language: json['language'] as String?,
      stars: json['stars'] as int? ?? 0,
      forks: json['forks'] as int? ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      htmlUrl: json['html_url'] as String? ?? '',
      isFork: json['is_fork'] as bool? ?? false,
    );
  }
}

class GitHubCommit {
  const GitHubCommit({
    required this.repo,
    required this.message,
    required this.date,
    required this.url,
  });

  final String repo;
  final String message;
  final DateTime date;
  final String url;

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    return GitHubCommit(
      repo: json['repo'] as String? ?? '',
      message: json['message'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      url: json['url'] as String? ?? '',
    );
  }
}

class GitHubActivity {
  const GitHubActivity({
    required this.username,
    required this.avatarUrl,
    required this.publicRepos,
    required this.followers,
    required this.following,
    required this.totalCommitsThisWeek,
    required this.contributionStreak,
    required this.repos,
    required this.recentCommits,
    required this.languages,
    required this.syncedAt,
  });

  final String username;
  final String avatarUrl;
  final int publicRepos;
  final int followers;
  final int following;
  final int totalCommitsThisWeek;
  final int contributionStreak;
  final List<GitHubRepo> repos;
  final List<GitHubCommit> recentCommits;
  final Map<String, int> languages;
  final DateTime syncedAt;

  factory GitHubActivity.fromJson(Map<String, dynamic> json) {
    final reposJson = json['repos'] as List<dynamic>? ?? const [];
    final commitsJson = json['recent_commits'] as List<dynamic>? ?? const [];
    final languagesJson = json['languages'] as Map<String, dynamic>? ?? const {};

    return GitHubActivity(
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      publicRepos: json['public_repos'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      totalCommitsThisWeek: json['total_commits_this_week'] as int? ?? 0,
      contributionStreak: json['contribution_streak'] as int? ?? 0,
      repos: reposJson
          .map((item) => GitHubRepo.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentCommits: commitsJson
          .map((item) => GitHubCommit.fromJson(item as Map<String, dynamic>))
          .toList(),
      languages: languagesJson.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      syncedAt: DateTime.tryParse(json['synced_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
