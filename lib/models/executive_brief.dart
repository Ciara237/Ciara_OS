class ExecutiveBriefMission {
  const ExecutiveBriefMission({
    required this.title,
    required this.reason,
    required this.estimatedMinutes,
  });

  final String title;
  final String reason;
  final int estimatedMinutes;

  factory ExecutiveBriefMission.fromJson(Map<String, dynamic> json) {
    return ExecutiveBriefMission(
      title: json['title'] as String,
      reason: json['reason'] as String,
      estimatedMinutes: json['estimated_minutes'] as int,
    );
  }
}

class ExecutiveBriefRisk {
  const ExecutiveBriefRisk({
    required this.present,
    this.description,
  });

  final bool present;
  final String? description;

  factory ExecutiveBriefRisk.fromJson(Map<String, dynamic> json) {
    return ExecutiveBriefRisk(
      present: json['present'] as bool,
      description: json['description'] as String?,
    );
  }
}

class ExecutiveBrief {
  const ExecutiveBrief({
    required this.greeting,
    required this.mission,
    required this.risk,
    required this.recommendation,
    required this.priorityScore,
    required this.expectedOutcome,
  });

  final String greeting;
  final ExecutiveBriefMission mission;
  final ExecutiveBriefRisk risk;
  final String recommendation;
  final int priorityScore;
  final String expectedOutcome;

  factory ExecutiveBrief.fromJson(Map<String, dynamic> json) {
    return ExecutiveBrief(
      greeting: json['greeting'] as String,
      mission: ExecutiveBriefMission.fromJson(
        json['mission'] as Map<String, dynamic>,
      ),
      risk: ExecutiveBriefRisk.fromJson(
        json['risk'] as Map<String, dynamic>,
      ),
      recommendation: json['recommendation'] as String,
      priorityScore: json['priority_score'] as int,
      expectedOutcome: json['expected_outcome'] as String,
    );
  }
}
