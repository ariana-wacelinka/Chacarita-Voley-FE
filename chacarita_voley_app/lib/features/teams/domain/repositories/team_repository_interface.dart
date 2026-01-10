import '../entities/team.dart';

abstract class TeamRepositoryInterface {
  Future<List<Team>> getTeams({String? searchQuery, int? page, int? size});
  Future<Team?> getTeamById(String id);
  Future<void> createTeam(Team team);
  Future<void> updateTeam(Team team);
  Future<void> deleteTeam(String id);
  Future<void> addPlayersToTeam(String teamId, List<String> playerIds);
  Future<void> addProfessorsToTeam(String teamId, List<String> professorIds);
  Future<void> removePlayersFromTeam(String teamId, List<String> playerIds);
  Future<void> removeProfessorsFromTeam(
    String teamId,
    List<String> professorIds,
  );
}
