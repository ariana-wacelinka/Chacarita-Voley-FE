import 'package:flutter/foundation.dart';
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
    return GraphQLClientFactory.client.query(options);
  }

  Future<QueryResult> _mutate(MutationOptions options) {
    final override = _clientOverride;
    if (override != null) return override.mutate(options);
    return GraphQLClientFactory.client.mutate(options);
  }

  // Query mínima para LISTADOS - Solo lo necesario para mostrar en tabla
  // Incluye: nombre, entrenador (professors.person), cantidad jugadores (players.id)
  static const String _teamFieldsMinimal = r'''
    id
    name
    abbreviation
    isCompetitive
    players {
      id
    }
    professors {
      id
      person {
        name
        surname
      }
    }
  ''';

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
      }
    }
    professors {
      id
      person {
        id
        dni
        name
        surname
      }
    }
    trainings {
      id
      dayOfWeek
      startTime
      endTime
      location
      trainingType
    }
  ''';

  String _getAllTeamsQuery({bool minimal = true}) =>
      '''
    query GetAllTeams(\$page: Int!, \$size: Int!, \$name: String) {
      getAllTeams(page: \$page, size: \$size, filters: {name: \$name}) {
        content {
          ${minimal ? _teamFieldsMinimal : _teamFields}
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

  @override
  Future<List<Team>> getTeams({
    String? searchQuery,
    int? page,
    int? size,
  }) async {
    final variables = <String, dynamic>{
      'page': page ?? 0,
      'size': size ?? 100,
      'name': searchQuery ?? '',
    };

    debugPrint('📤 getTeams called');
    debugPrint('📤 Variables: $variables');

    final result = await _query(
      QueryOptions(
        document: gql(_getAllTeamsQuery(minimal: true)),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    debugPrint('📥 Raw GraphQL result: ${result.data}');

    if (result.hasException) {
      debugPrint('❌ GraphQL exception: ${result.exception}');
      debugPrint('❌ GraphQL errors: ${result.exception?.graphqlErrors}');
      debugPrint('❌ Link exception: ${result.exception?.linkException}');
      throw Exception(result.exception.toString());
    }

    final content =
        (result.data?['getAllTeams']?['content'] as List<dynamic>?) ?? const [];

    debugPrint('📥 Teams count: ${content.length}');

    return content
        .whereType<Map<String, dynamic>>()
        .map((data) => _mapTeamResponseToTeam(TeamResponseModel.fromJson(data)))
        .toList();
  }

  @override
  Future<int> getTotalTeams({String? searchQuery}) async {
    final variables = <String, dynamic>{
      'page': 0,
      'size': 1,
      'name': searchQuery ?? '',
    };

    final result = await _query(
      QueryOptions(
        document: gql(_getAllTeamsQuery(minimal: true)),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return (result.data?['getAllTeams']?['totalElements'] as int?) ?? 0;
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
    final playerIds = team.integrantes
        .where((m) => m.playerId != null)
        .map((m) => m.playerId!)
        .toList();

    final professorIds = team.entrenador.isNotEmpty
        ? [team.entrenador]
        : <String>[];

    final request = CreateTeamRequestModel(
      name: team.nombre,
      abbreviation: team.abreviacion,
      isCompetitive: team.tipo == TeamType.competitivo,
      playerIds: playerIds,
      professorIds: professorIds,
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
  }

  @override
  Future<void> updateTeam(Team team) async {
    final playerIds = team.integrantes
        .where((m) => m.playerId != null)
        .map((m) => m.playerId!)
        .toList();

    final professorIds = team.entrenador.isNotEmpty
        ? [team.entrenador]
        : <String>[];

    final request = UpdateTeamRequestModel(
      id: team.id,
      name: team.nombre,
      abbreviation: team.abreviacion,
      isCompetitive: team.tipo == TeamType.competitivo,
      playerIds: playerIds,
      professorIds: professorIds,
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
          ? '${model.professors!.first.person?.name ?? ''} ${model.professors!.first.person?.surname ?? ''}'
                .trim()
          : '',
      integrantes: (model.players ?? [])
          .map(
            (player) => TeamMember(
              playerId: player.id,
              // En query mínima, person puede ser null
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
