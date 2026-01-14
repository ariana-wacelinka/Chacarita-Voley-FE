import '../entities/team.dart';

abstract class TeamRepositoryInterface {
  Future<List<Team>> getTeams({String? searchQuery, int? page, int? size});
  Future<int> getTotalTeams({String? searchQuery});
  Future<Team?> getTeamById(String id);
  Future<void> createTeam(Team team);
  Future<void> updateTeam(Team team);
  Future<void> deleteTeam(String id);
}
