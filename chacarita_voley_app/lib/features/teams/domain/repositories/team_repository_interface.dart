import '../entities/team.dart';

abstract class TeamRepositoryInterface {
  Future<List<Team>> getTeams();
  Future<Team?> getTeamById(String id);
  Future<void> createTeam(Team team);
  Future<void> updateTeam(Team team);
  Future<void> deleteTeam(String id);
}
