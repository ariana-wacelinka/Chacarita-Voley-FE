import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import 'team_service_interface.dart';
import '../models/team_response_model.dart';

class TeamService implements TeamServiceInterface {
  final GraphQLClient _graphQLClient;

  TeamService({required GraphQLClient graphQLClient})
    : _graphQLClient = graphQLClient;

  static const String _createTeamMutation = r'''
    mutation CreateTeam($input: CreateTeamInput!) {
      createTeam(input: $input) {
        id
        abbreviation
        isCompetitive
        name
        players { id jerseyNumber leagueId }
        professors { id }
        trainings { dayOfWeek endTime id location startTime trainingType }
      }
    }
  ''';

  @override
  Future<TeamResponseModel> createTeam(CreateTeamRequestModel request) async {
    final result = await _graphQLClient.mutate(
      MutationOptions(
        document: gql(_createTeamMutation),
        variables: {'input': request.toJson()},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return TeamResponseModel.fromJson(
      result.data!['createTeam'] as Map<String, dynamic>,
    );
  }

  static const String _updateTeamMutation = r'''
    mutation UpdateTeam($id: ID!, $input: UpdateTeamInput!) {
      updateTeam(id: $id, input: $input) {
        id
        abbreviation
        isCompetitive
        name
        players { id jerseyNumber leagueId }
        professors { id }
        trainings { dayOfWeek endTime id location startTime trainingType }
      }
    }
  ''';

  @override
  Future<TeamResponseModel> updateTeam(UpdateTeamRequestModel request) async {
    final variables = request.toJson();
    final id = variables.remove('id');

    final result = await _graphQLClient.mutate(
      MutationOptions(
        document: gql(_updateTeamMutation),
        variables: {'id': id, 'input': variables},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return TeamResponseModel.fromJson(
      result.data!['updateTeam'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteTeam(String id) async {
    const mutation = r'''
      mutation deleteTeam($id: ID!) {
        deleteTeam(id: $id)
      }
    ''';

    final result = await _graphQLClient.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    // El backend devuelve true/false, no un objeto
    final deleted = result.data?['deleteTeam'] as bool?;

    if (deleted != true) {
      throw Exception('No se pudo eliminar el equipo');
    }

    // Resetear cache para forzar refetch en próxima query
    _graphQLClient.cache.store.reset();
  }

  static const String _getAllTeamsQuery = r'''
    query GetAllTeams($page: Int!, $size: Int!) {
      getAllTeams(page: $page, size: $size) {
        content {
          abbreviation
          id
          name
          isCompetitive
          players {
            id
            jerseyNumber
            leagueId
          }
          professors {
            id
          }
          trainings {
            dayOfWeek
            endTime
            id
            location
            startTime
            trainingType
          }
        }
        hasNext
        hasPrevious
        pageNumber
        pageSize
        totalElements
        totalPages
      }
    }
  ''';

  @override
  Future<PaginatedTeamResponse> getAllTeams({
    required int page,
    required int size,
    TeamFilters? filters,
  }) async {
    final result = await GraphQLClientFactory.withFreshClient(
      run: (freshClient) => freshClient.query(
        QueryOptions(
          document: gql(_getAllTeamsQuery),
          variables: {'page': page, 'size': size},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return PaginatedTeamResponse.fromJson(
      result.data!['getAllTeams'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<TeamResponseModel>> getTeams() async {
    final paginatedResponse = await getAllTeams(page: 0, size: 100);
    return paginatedResponse.content;
  }

  static const String _getTeamByIdQuery = r'''
    query GetTeamById($id: ID!) {
      getTeamById(id: $id) {
        abbreviation
        id
        isCompetitive
        name
        players {
          id
          jerseyNumber
          leagueId
        }
        professors { id }
        trainings { dayOfWeek endTime id location startTime trainingType }
      }
    }
  ''';

  @override
  Future<TeamResponseModel?> getTeamById(String id) async {
    final result = await _graphQLClient.query(
      QueryOptions(document: gql(_getTeamByIdQuery), variables: {'id': id}),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    if (result.data?['getTeamById'] == null) {
      return null;
    }

    return TeamResponseModel.fromJson(
      result.data!['getTeamById'] as Map<String, dynamic>,
    );
  }

  static const String _addPlayersToTeamMutation = r'''
    mutation AddPlayersToTeam($teamId: ID!, $playersIds: String!) {
      addPlayersToTeam(teamId: $teamId, playersIds: $playersIds) {
        id
        isCompetitive
        name
        players { id }
        professors { id }
        trainings { dayOfWeek endTime id location startTime trainingType }
      }
    }
  ''';

  @override
  Future<TeamResponseModel> addPlayersToTeam(
    String teamId,
    List<String> playerIds,
  ) async {
    final result = await _graphQLClient.mutate(
      MutationOptions(
        document: gql(_addPlayersToTeamMutation),
        variables: {'teamId': teamId, 'playersIds': playerIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return TeamResponseModel.fromJson(
      result.data!['addPlayersToTeam'] as Map<String, dynamic>,
    );
  }

  static const String _addProfessorsToTeamMutation = r'''
    mutation AddProfessorsToTeam($teamId: ID!, $professorsIds: String!) {
      addProfessorsToTeam(teamId: $teamId, professorsIds: $professorsIds) {
        id
        isCompetitive
        name
        players { id }
        professors { id }
        trainings { dayOfWeek endTime id location startTime trainingType }
      }
    }
  ''';

  @override
  Future<TeamResponseModel> addProfessorsToTeam(
    String teamId,
    List<String> professorIds,
  ) async {
    final result = await _graphQLClient.mutate(
      MutationOptions(
        document: gql(_addProfessorsToTeamMutation),
        variables: {'teamId': teamId, 'professorsIds': professorIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return TeamResponseModel.fromJson(
      result.data!['addProfessorsToTeam'] as Map<String, dynamic>,
    );
  }

  static const String _removePlayersFromTeamMutation = r'''
    mutation RemovePlayersFromTeam($teamId: ID!, $playerIds: String!) {
      removePlayersToTeam(teamId: $teamId, playerIds: $playerIds) {
        id
        isCompetitive
        name
        players { id }
        professors { id }
        trainings { dayOfWeek endTime id location startTime trainingType }
      }
    }
  ''';

  @override
  Future<TeamResponseModel> removePlayersFromTeam(
    String teamId,
    List<String> playerIds,
  ) async {
    final result = await _graphQLClient.mutate(
      MutationOptions(
        document: gql(_removePlayersFromTeamMutation),
        variables: {'teamId': teamId, 'playerIds': playerIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return TeamResponseModel.fromJson(
      result.data!['removePlayersToTeam'] as Map<String, dynamic>,
    );
  }

  static const String _removeProfessorsFromTeamMutation = r'''
    mutation RemoveProfessorsFromTeam($teamId: ID!, $professorsIds: String!) {
      removeProfessorsToTeam(teamId: $teamId, professorsIds: $professorsIds) {
        id
        isCompetitive
        name
        players { id }
        professors { id }
        trainings { dayOfWeek endTime id location startTime trainingType }
      }
    }
  ''';

  @override
  Future<TeamResponseModel> removeProfessorsFromTeam(
    String teamId,
    List<String> professorIds,
  ) async {
    final result = await _graphQLClient.mutate(
      MutationOptions(
        document: gql(_removeProfessorsFromTeamMutation),
        variables: {'teamId': teamId, 'professorsIds': professorIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return TeamResponseModel.fromJson(
      result.data!['removeProfessorsToTeam'] as Map<String, dynamic>,
    );
  }
}
