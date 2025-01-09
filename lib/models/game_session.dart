class GameSession {
  final String id;
  final String userId;
  final Map<String, int> score;
  final int ruleChanges;
  final int durationSeconds;
  final DateTime createdAt;
  final DateTime? completedAt;

  GameSession({
    required this.id,
    required this.userId,
    required this.score,
    required this.ruleChanges,
    required this.durationSeconds,
    required this.createdAt,
    this.completedAt,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'],
      userId: json['user_id'],
      score: Map<String, int>.from(json['score']),
      ruleChanges: json['rule_changes'],
      durationSeconds: json['duration_seconds'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'score': score,
      'rule_changes': ruleChanges,
      'duration_seconds': durationSeconds,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
} 