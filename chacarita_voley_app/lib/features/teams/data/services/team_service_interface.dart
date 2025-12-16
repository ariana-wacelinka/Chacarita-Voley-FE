import '../models/team_response_model.dart';

abstract class TeamServiceInterface {
  Future<List<TeamResponseModel>> getTeams();
  Future<TeamResponseModel?> getTeamById(String id);
  Future<TeamResponseModel> createTeam(CreateTeamRequestModel request);
  Future<TeamResponseModel> updateTeam(UpdateTeamRequestModel request);
  Future<void> deleteTeam(String id);
  Future<TeamResponseModel> addPlayersToTeam(
    String teamId,
    List<String> playerIds,
  );
  Future<TeamResponseModel> addProfessorsToTeam(
    String teamId,
    List<String> professorIds,
  );
  Future<TeamResponseModel> removePlayersFromTeam(
    String teamId,
    List<String> playerIds,
  );
  Future<TeamResponseModel> removeProfessorsFromTeam(
    String teamId,
    List<String> professorIds,
  );
}
