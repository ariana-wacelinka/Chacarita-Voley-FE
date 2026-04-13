class TeamUpdateConflict {
  final String key;
  final String? playerId;
  final String? conflictingTeamId;
  final String? conflictingTeamName;
  final bool? conflictingTeamIsCompetitive;

  TeamUpdateConflict({
    required this.key,
    this.playerId,
    this.conflictingTeamId,
    this.conflictingTeamName,
    this.conflictingTeamIsCompetitive,
  });

  factory TeamUpdateConflict.fromJson(Map<String, dynamic> json) {
    return TeamUpdateConflict(
      key: json['key'] as String? ?? '',
      playerId: json['playerId']?.toString(),
      conflictingTeamId: json['conflictingTeamId']?.toString(),
      conflictingTeamName: json['conflictingTeamName'] as String?,
      conflictingTeamIsCompetitive:
          json['conflictingTeamIsCompetitive'] as bool?,
    );
  }
}

class AttemptUpdateTeamResult {
  final bool hasConflicts;
  final List<TeamUpdateConflict> conflicts;

  AttemptUpdateTeamResult({
    required this.hasConflicts,
    required this.conflicts,
  });

  factory AttemptUpdateTeamResult.fromJson(Map<String, dynamic> json) {
    return AttemptUpdateTeamResult(
      hasConflicts: json['hasConflicts'] as bool? ?? false,
      conflicts: (json['conflicts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TeamUpdateConflict.fromJson)
          .toList(),
    );
  }
}

class ApplyUpdateTeamResult {
  final bool applied;
  final bool hasConflicts;
  final List<TeamUpdateConflict> conflicts;

  ApplyUpdateTeamResult({
    required this.applied,
    required this.hasConflicts,
    required this.conflicts,
  });

  factory ApplyUpdateTeamResult.fromJson(Map<String, dynamic> json) {
    return ApplyUpdateTeamResult(
      applied: json['applied'] as bool? ?? false,
      hasConflicts: json['hasConflicts'] as bool? ?? false,
      conflicts: (json['conflicts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TeamUpdateConflict.fromJson)
          .toList(),
    );
  }
}
