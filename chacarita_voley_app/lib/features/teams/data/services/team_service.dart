import 'team_service_interface.dart';
import '../models/team_response_model.dart';

class TeamService implements TeamServiceInterface {
  // TODO: Inyectar GraphQL client cuando esté configurado
  // final GraphQLClient _graphQLClient;

  TeamService();
  // TeamService({
  //   required GraphQLClient graphQLClient,
  // }) : _graphQLClient = graphQLClient;

  // TODO: Implementar mutation createTeam
  // mutation CreateTeam($input: CreateTeamInput!) {
  //   createTeam(input: $input) {
  //     id
  //     isCompetitive
  //     name
  //     players { id }
  //     professors { id }
  //     trainings { dayOfWeek endTime id location startTime trainingType }
  //   }
  // }
  @override
  Future<TeamResponseModel> createTeam(CreateTeamRequestModel request) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('createTeam no implementado');
  }

  // TODO: Implementar mutation updateTeam
  // mutation UpdateTeam($id: String!, $input: UpdateTeamInput!) {
  //   updateTeam(id: $id, input: $input) {
  //     id
  //     isCompetitive
  //     name
  //     players { id }
  //     professors { id }
  //     trainings { dayOfWeek endTime id location startTime trainingType }
  //   }
  // }
  @override
  Future<TeamResponseModel> updateTeam(UpdateTeamRequestModel request) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('updateTeam no implementado');
  }

  // TODO: Implementar mutation deleteTeam
  // mutation DeleteTeam($id: String!) {
  //   deleteTeam(id: $id)
  // }
  @override
  Future<void> deleteTeam(String id) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('deleteTeam no implementado');
  }

  // TODO: Implementar query getTeams
  // query GetTeams {
  //   teams {
  //     id
  //     isCompetitive
  //     name
  //     players { id }
  //     professors { id }
  //     trainings { dayOfWeek endTime id location startTime trainingType }
  //   }
  // }
  @override
  Future<List<TeamResponseModel>> getTeams() async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('getTeams no implementado');
  }

  // TODO: Implementar query getTeamById
  // query GetTeamById($id: String!) {
  //   team(id: $id) {
  //     id
  //     isCompetitive
  //     name
  //     players { id }
  //     professors { id }
  //     trainings { dayOfWeek endTime id location startTime trainingType }
  //   }
  // }
  @override
  Future<TeamResponseModel?> getTeamById(String id) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('getTeamById no implementado');
  }

  // TODO: Implementar mutation addPlayersToTeam
  // mutation AddPlayersToTeam($teamId: String!, $playerIds: String!) {
  //   addPlayersToTeam(teamId: $teamId, playersIds: $playerIds) {
  //     id
  //     isCompetitive
  //     name
  //     players { id }
  //     professors { id }
  //     trainings { dayOfWeek endTime id location startTime trainingType }
  //   }
  // }
  @override
  Future<TeamResponseModel> addPlayersToTeam(
    String teamId,
    List<String> playerIds,
  ) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('addPlayersToTeam no implementado');
  }

  // TODO: Implementar mutation addProfessorsToTeam
  // mutation AddProfessorsToTeam($teamId: String!, $professorIds: String!) {
  //   addProfessorsToTeam(teamId: $teamId, professorsIds: $professorIds) {
  //     id
  //     isCompetitive
  //     name
  //     players { id }
  //     professors { id }
  //   }
  // }
  @override
  Future<TeamResponseModel> addProfessorsToTeam(
    String teamId,
    List<String> professorIds,
  ) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('addProfessorsToTeam no implementado');
  }

  // TODO: Implementar mutation removePlayersFromTeam
  // mutation RemovePlayersFromTeam($teamId: String!, $playerIds: String!) {
  //   removePlayersToTeam(teamId: $teamId, playerIds: $playerIds) {
  //     id
  //     isCompetitive
  //     name
  //     players { id }
  //     professors { id }
  //   }
  // }
  @override
  Future<TeamResponseModel> removePlayersFromTeam(
    String teamId,
    List<String> playerIds,
  ) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('removePlayersFromTeam no implementado');
  }

  // TODO: Implementar mutation removeProfessorsFromTeam
  // mutation RemoveProfessorsFromTeam($teamId: String!, $professorIds: String!) {
  //   removeProfessorsToTeam(teamId: $teamId, professorsIds: $professorIds) {
  //     id
  //     isCompetitive
  //     name
  //     professors { id }
  //   }
  // }
  @override
  Future<TeamResponseModel> removeProfessorsFromTeam(
    String teamId,
    List<String> professorIds,
  ) async {
    // TODO: Implementar llamada a GraphQL
    throw UnimplementedError('removeProfessorsFromTeam no implementado');
  }
}
