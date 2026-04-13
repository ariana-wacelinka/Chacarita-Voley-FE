import '../entities/team.dart';
import '../entities/team_list_item.dart';
import '../entities/team_detail.dart';
import '../entities/team_update_conflict.dart';

abstract class TeamRepositoryInterface {
  Future<List<TeamListItem>> getTeamsListItems({
    String? searchQuery,
    String? professorId,
    bool? isCompetitive,
    String? playerId,
    int? page,
    int? size,
    bool includeDeleted = false,
  });
  Future<List<Team>> getTeams({
    String? searchQuery,
    String? professorId,
    bool? isCompetitive,
    String? playerId,
    int? page,
    int? size,
    bool includeDeleted = false,
  });
  Future<int> getTotalTeams({
    String? searchQuery,
    String? professorId,
    bool? isCompetitive,
    String? playerId,
    bool includeDeleted = false,
  });
  Future<TeamDetail?> getTeamDetailById(String id);
  Future<Team?> getTeamById(String id);
  Future<void> createTeam(Team team);
  Future<void> updateTeam(Team team);
  Future<AttemptUpdateTeamResult> attemptUpdateTeam(Team team);
  Future<ApplyUpdateTeamResult> applyUpdateTeam(
    Team team,
    List<String> selectedConflictKeys,
  );
  Future<void> deleteTeam(String id);
  Future<void> restoreTeam(String id);
}
