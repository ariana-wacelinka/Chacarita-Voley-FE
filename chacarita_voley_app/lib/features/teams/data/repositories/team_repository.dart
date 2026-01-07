import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository_interface.dart';
import '../models/team_response_model.dart';

class TeamRepository implements TeamRepositoryInterface {
  TeamRepository({GraphQLClient? graphQLClient})
    : _clientOverride = graphQLClient;

  final GraphQLClient? _clientOverride;

  Future<QueryResult> _query(QueryOptions options) {
    final override = _clientOverride;
    if (override != null) return override.query(options);
    return GraphQLClientFactory.withFreshClient(run: (c) => c.query(options));
  }

  Future<QueryResult> _mutate(MutationOptions options) {
    final override = _clientOverride;
    if (override != null) return override.mutate(options);
    return GraphQLClientFactory.withFreshClient(run: (c) => c.mutate(options));
  }

  static const String _teamFields = r'''
    id
    abbreviation
    isCompetitive
    name
    players {
      id
      jerseyNumber
      leagueId
      person {
        id
        dni
        name
        surname
        phone
        email
        gender
        birthDate
        roles
      }
    }
    professors {
      id
      person {
        id
        dni
        name
        surname
        phone
        email
        gender
        birthDate
        roles
      }
    }
    trainings {
      dayOfWeek
      endTime
      id
      location
      startTime
      trainingType
    }
  ''';

  String _getAllTeamsQuery() =>
      '''
    query GetAllTeams(\$page: Int!, \$size: Int!) {
      getAllTeams(page: \$page, size: \$size) {
        content {
          $_teamFields
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

  String _getTeamByIdQuery() =>
      '''
    query GetTeamById(\$id: ID!) {
      getTeamById(id: \$id) {
        $_teamFields
      }
    }
  ''';

  String _createTeamMutation() =>
      '''
    mutation CreateTeam(\$input: CreateTeamInput!) {
      createTeam(input: \$input) {
        $_teamFields
      }
    }
  ''';

  String _updateTeamMutation() =>
      '''
    mutation UpdateTeam(\$id: ID!, \$input: UpdateTeamInput!) {
      updateTeam(id: \$id, input: \$input) {
        $_teamFields
      }
    }
  ''';

  static const String _deleteTeamMutation = r'''
    mutation DeleteTeam($id: ID!) {
      deleteTeam(id: $id)
    }
  ''';

  static const String _addPlayersToTeamMutation = r'''
    mutation AddPlayersToTeam($teamId: ID!, $playersIds: String!) {
      addPlayersToTeam(teamId: $teamId, playersIds: $playersIds) {
        id
        isCompetitive
        name
        abbreviation
        players {
          id
          jerseyNumber
          leagueId
          person {
            dni
            name
            surname
          }
        }
        professors { id }
        trainings { id }
      }
    }
  ''';

  static const String _addProfessorsToTeamMutation = r'''
    mutation AddProfessorsToTeam($teamId: ID!, $professorsIds: String!) {
      addProfessorsToTeam(teamId: $teamId, professorsIds: $professorsIds) {
        id
        isCompetitive
        name
        abbreviation
        players {
          id
          jerseyNumber
          person {
            dni
            name
            surname
          }
        }
        professors {
          id
          person {
            dni
            name
            surname
          }
        }
        trainings { id }
      }
    }
  ''';

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
  Future<List<Team>> getTeams() async {
    final result = await _query(
      QueryOptions(
        document: gql(_getAllTeamsQuery()),
        variables: {'page': 0, 'size': 100},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final content =
        (result.data?['getAllTeams']?['content'] as List<dynamic>?) ?? const [];

    return content
        .whereType<Map<String, dynamic>>()
        .map((data) => _mapTeamResponseToTeam(TeamResponseModel.fromJson(data)))
        .toList();
  }

  @override
  Future<Team?> getTeamById(String id) async {
    final result = await _query(
      QueryOptions(
        document: gql(_getTeamByIdQuery()),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['getTeamById'] as Map<String, dynamic>?;
    if (data == null) return null;
    return _mapTeamResponseToTeam(TeamResponseModel.fromJson(data));
  }

  @override
  Future<void> createTeam(Team team) async {
    final request = CreateTeamRequestModel(
      name: team.nombre,
      abbreviation: team.abreviacion,
      isCompetitive: team.tipo == TeamType.competitivo,
      playerIds: [],
      professorIds: [],
    );

    final result = await _mutate(
      MutationOptions(
        document: gql(_createTeamMutation()),
        variables: {'input': request.toJson()},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['createTeam'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Respuesta inválida de createTeam');
    }

    final createdTeam = TeamResponseModel.fromJson(data);

    final playerIds = team.integrantes
        .where((m) => m.playerId != null)
        .map((m) => m.playerId!)
        .toList();
    if (playerIds.isNotEmpty) {
      await _addPlayersToTeam(createdTeam.id, playerIds);
    }

    if (team.entrenador.isNotEmpty) {
      await _addProfessorsToTeam(createdTeam.id, [team.entrenador]);
    }
  }

  @override
  Future<void> updateTeam(Team team) async {
    final request = UpdateTeamRequestModel(
      id: team.id,
      name: team.nombre,
      abbreviation: team.abreviacion,
      isCompetitive: team.tipo == TeamType.competitivo,
    );

    final variables = request.toJson();
    final id = variables.remove('id');

    final result = await _mutate(
      MutationOptions(
        document: gql(_updateTeamMutation()),
        variables: {'id': id, 'input': variables},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final currentTeam = await getTeamById(team.id);
    if (currentTeam != null) {
      final currentPlayerIds = currentTeam.integrantes
          .where((m) => m.playerId != null)
          .map((m) => m.playerId!)
          .toSet();
      final newPlayerIds = team.integrantes
          .where((m) => m.playerId != null)
          .map((m) => m.playerId!)
          .toSet();

      final currentProfessorIds = currentTeam.entrenador.isNotEmpty
          ? {currentTeam.entrenador}
          : <String>{};
      final newProfessorIds = team.entrenador.isNotEmpty
          ? {team.entrenador}
          : <String>{};

      final playersToAdd = newPlayerIds.difference(currentPlayerIds).toList();
      if (playersToAdd.isNotEmpty) {
        await _addPlayersToTeam(team.id, playersToAdd);
      }

      final playersToRemove = currentPlayerIds
          .difference(newPlayerIds)
          .toList();
      if (playersToRemove.isNotEmpty) {
        await _removePlayersFromTeam(team.id, playersToRemove);
      }

      final professorsToAdd = newProfessorIds
          .difference(currentProfessorIds)
          .toList();
      if (professorsToAdd.isNotEmpty) {
        await _addProfessorsToTeam(team.id, professorsToAdd);
      }

      final professorsToRemove = currentProfessorIds
          .difference(newProfessorIds)
          .toList();
      if (professorsToRemove.isNotEmpty) {
        await _removeProfessorsFromTeam(team.id, professorsToRemove);
      }
    }
  }

  @override
  Future<void> deleteTeam(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_deleteTeamMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final deleted = result.data?['deleteTeam'] as bool?;
    if (deleted != true) {
      throw Exception('No se pudo eliminar el equipo');
    }
  }

  Future<void> _addPlayersToTeam(String teamId, List<String> playerIds) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_addPlayersToTeamMutation),
        variables: {'teamId': teamId, 'playersIds': playerIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> _addProfessorsToTeam(
    String teamId,
    List<String> professorIds,
  ) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_addProfessorsToTeamMutation),
        variables: {'teamId': teamId, 'professorsIds': professorIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> _removePlayersFromTeam(
    String teamId,
    List<String> playerIds,
  ) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_removePlayersFromTeamMutation),
        variables: {'teamId': teamId, 'playerIds': playerIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> _removeProfessorsFromTeam(
    String teamId,
    List<String> professorIds,
  ) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_removeProfessorsFromTeamMutation),
        variables: {'teamId': teamId, 'professorsIds': professorIds.join(',')},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Team _mapTeamResponseToTeam(TeamResponseModel model) {
    return Team(
      id: model.id,
      nombre: model.name,
      abreviacion:
          model.abbreviation ??
          model.name
              .substring(0, model.name.length > 4 ? 4 : model.name.length)
              .toUpperCase(),
      tipo: model.isCompetitive ? TeamType.competitivo : TeamType.recreativo,
      entrenador: (model.professors != null && model.professors!.isNotEmpty)
          ? model.professors!.first.id
          : '',
      integrantes: (model.players ?? [])
          .map(
            (player) => TeamMember(
              playerId: player.id,
              dni: player.person?.dni ?? '',
              nombre: player.person?.name ?? '',
              apellido: player.person?.surname ?? '',
              numeroCamiseta: player.jerseyNumber?.toString(),
            ),
          )
          .toList(),
    );
  }
}
