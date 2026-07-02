class HackTheBoxActivity {
  const HackTheBoxActivity({
    required this.name,
    required this.type,
    required this.difficulty,
    required this.points,
    required this.date,
  });

  final String name;
  final String type;
  final String difficulty;
  final int points;
  final DateTime date;

  factory HackTheBoxActivity.fromJson(Map<String, dynamic> json) {
    return HackTheBoxActivity(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'machine',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      points: json['points'] as int? ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class HackTheBoxProfile {
  const HackTheBoxProfile({
    required this.username,
    required this.avatarUrl,
    required this.rank,
    required this.points,
    required this.globalRank,
    required this.machinesOwned,
    required this.challengesSolved,
    required this.streak,
    required this.skillCoverage,
    required this.recentActivity,
    required this.syncedAt,
  });

  final String username;
  final String avatarUrl;
  final String rank;
  final int points;
  final int globalRank;
  final int machinesOwned;
  final int challengesSolved;
  final int streak;
  final Map<String, int> skillCoverage;
  final List<HackTheBoxActivity> recentActivity;
  final DateTime syncedAt;

  factory HackTheBoxProfile.fromJson(Map<String, dynamic> json) {
    final activityJson = json['recent_activity'] as List<dynamic>? ?? const [];
    final skillsJson = json['skill_coverage'] as Map<String, dynamic>? ?? const {};

    return HackTheBoxProfile(
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      rank: json['rank'] as String? ?? 'Unranked',
      points: json['points'] as int? ?? 0,
      globalRank: json['global_rank'] as int? ?? 0,
      machinesOwned: json['machines_owned'] as int? ?? 0,
      challengesSolved: json['challenges_solved'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      skillCoverage: skillsJson.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      recentActivity: activityJson
          .map(
            (item) => HackTheBoxActivity.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      syncedAt: DateTime.tryParse(json['synced_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class HackerOneReport {
  const HackerOneReport({
    required this.title,
    required this.program,
    required this.severity,
    required this.status,
    required this.date,
    this.bounty,
  });

  final String title;
  final String program;
  final String severity;
  final String status;
  final DateTime date;
  final double? bounty;

  factory HackerOneReport.fromJson(Map<String, dynamic> json) {
    return HackerOneReport(
      title: json['title'] as String? ?? '',
      program: json['program'] as String? ?? '',
      severity: json['severity'] as String? ?? 'info',
      status: json['status'] as String? ?? 'new',
      date: DateTime.tryParse(json['date'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      bounty: (json['bounty'] as num?)?.toDouble(),
    );
  }
}

class BountySummary {
  const BountySummary({
    required this.totalEarned,
    required this.bySeverity,
  });

  final double totalEarned;
  final Map<String, double> bySeverity;

  factory BountySummary.fromJson(Map<String, dynamic> json) {
    final bySeverityJson =
        json['by_severity'] as Map<String, dynamic>? ?? const {};
    return BountySummary(
      totalEarned: (json['total_earned'] as num?)?.toDouble() ?? 0,
      bySeverity: bySeverityJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }
}

class HackerOneProfile {
  const HackerOneProfile({
    required this.username,
    required this.reputation,
    required this.signal,
    required this.impact,
    required this.reportsSubmitted,
    required this.reportsResolved,
    required this.thanksCount,
    required this.recentReports,
    required this.bountySummary,
    required this.syncedAt,
  });

  final String username;
  final int reputation;
  final double signal;
  final double impact;
  final int reportsSubmitted;
  final int reportsResolved;
  final int thanksCount;
  final List<HackerOneReport> recentReports;
  final BountySummary bountySummary;
  final DateTime syncedAt;

  factory HackerOneProfile.fromJson(Map<String, dynamic> json) {
    final reportsJson = json['recent_reports'] as List<dynamic>? ?? const [];

    return HackerOneProfile(
      username: json['username'] as String? ?? '',
      reputation: json['reputation'] as int? ?? 0,
      signal: (json['signal'] as num?)?.toDouble() ?? 0,
      impact: (json['impact'] as num?)?.toDouble() ?? 0,
      reportsSubmitted: json['reports_submitted'] as int? ?? 0,
      reportsResolved: json['reports_resolved'] as int? ?? 0,
      thanksCount: json['thanks_count'] as int? ?? 0,
      recentReports: reportsJson
          .map((item) => HackerOneReport.fromJson(item as Map<String, dynamic>))
          .toList(),
      bountySummary: BountySummary.fromJson(
        json['bounty_summary'] as Map<String, dynamic>? ?? const {},
      ),
      syncedAt: DateTime.tryParse(json['synced_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class SecurityManualLog {
  const SecurityManualLog({
    required this.platform,
    required this.activityType,
    required this.name,
    this.difficulty,
    this.date,
    this.notes,
  });

  final String platform;
  final String activityType;
  final String name;
  final String? difficulty;
  final String? date;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'activity_type': activityType,
      'name': name,
      if (difficulty != null) 'difficulty': difficulty,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
    };
  }
}
