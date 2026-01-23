import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../../domain/entities/training.dart';
import '../../domain/repositories/training_repository_interface.dart';

class TrainingRepository implements TrainingRepositoryInterface {
  TrainingRepository({GraphQLClient? graphQLClient})
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

  static const String _createTrainingMutation = r'''
    mutation CreateTraining($input: CreateTrainingInput!) {
      createTraining(input: $input) {
        id
        dayOfWeek
        startTime
        endTime
        location
        trainingType
      }
    }
  ''';

  static const String _updateTrainingMutation = r'''
    mutation UpdateTraining($id: ID!, $input: UpdateTrainingInput!) {
      updateTraining(id: $id, input: $input) {
        id
        dayOfWeek
        startTime
        endTime
        location
        trainingType
      }
    }
  ''';

  static const String _deleteTrainingMutation = r'''
    mutation DeleteTraining($id: ID!) {
      deleteTraining(id: $id)
    }
  ''';

  String _getAllSessionsQuery() => '''
    query GetAllSessions(\$page: Int!, \$size: Int!) {
      getAllSessions(page: \$page, size: \$size) {
        totalPages
        totalElements
        pageSize
        pageNumber
        hasPrevious
        hasNext
        content {
          id
          date
          startTime
          endTime
          location
          trainingType
          status
          team {
            id
            name
            abbreviation
            isCompetitive
          }
          training {
            id
            dayOfWeek
            startTime
            endTime
            location
            trainingType
          }
        }
      }
    }
  ''';

  String _getSessionByIdQuery() => '''
    query GetSessionById(\$id: ID!) {
      getSessionById(id: \$id) {
        id
        date
        startTime
        endTime
        location
        trainingType
        status
        team {
          id
          name
          abbreviation
          isCompetitive
          professors {
            id
            person {
              id
              name
              surname
            }
          }
          players {
            id
            jerseyNumber
            leagueId
            person {
              id
              name
              surname
            }
            assistances {
              id
              date
              assistance
            }
          }
        }
        training {
          id
          dayOfWeek
          startTime
          endTime
          location
          trainingType
        }
      }
    }
  ''';

  @override
  Future<List<Training>> getTrainings({
    DateTime? startDate,
    DateTime? endDate,
    String? teamId,
    TrainingStatus? status,
    int page = 0,
    int size = 10,
  }) async {
    final result = await _query(
      QueryOptions(
        document: gql(_getAllSessionsQuery()),
        variables: {'page': page, 'size': size},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final sessionsData = result.data?['getAllSessions'];
    if (sessionsData == null) return [];

    final content = (sessionsData['content'] as List<dynamic>?) ?? const [];

    return content
        .whereType<Map<String, dynamic>>()
        .map((data) => _mapSessionFromBackend(data))
        .toList();
  }

  @override
  Future<Training?> getTrainingById(String id) async {
    final result = await _query(
      QueryOptions(
        document: gql(_getSessionByIdQuery()),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['getSessionById'] as Map<String, dynamic>?;
    if (data == null) return null;

    return _mapSessionDetailFromBackend(data);
  }

  @override
  Future<Training> createTraining(Training training) async {
    final input = {
      'dayOfWeek': training.dayOfWeek?.backendValue ?? 'MONDAY',
      'startTime': training.startTime,
      'endTime': training.endTime,
      'trainingType': training.type.backendValue,
      'location': training.location,
    };

    final result = await _mutate(
      MutationOptions(
        document: gql(_createTrainingMutation),
        variables: {'input': input},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['createTraining'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Respuesta inválida de createTraining');
    }

    return _mapTrainingFromBackend(data);
  }

  @override
  Future<Training> updateTraining(Training training) async {
    final input = {
      'dayOfWeek': training.dayOfWeek?.backendValue ?? 'MONDAY',
      'startTime': training.startTime,
      'endTime': training.endTime,
      'trainingType': training.type.backendValue,
      'location': training.location,
    };

    final result = await _mutate(
      MutationOptions(
        document: gql(_updateTrainingMutation),
        variables: {'id': training.id, 'input': input},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['updateTraining'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Respuesta inválida de updateTraining');
    }

    return _mapTrainingFromBackend(data);
  }

  @override
  Future<void> deleteTraining(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_deleteTrainingMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  @override
  Future<Training> updateAttendance(
    String trainingId,
    List<PlayerAttendance> attendances,
  ) async {
    throw UnimplementedError('updateAttendance not yet implemented');
  }

  Training _mapSessionFromBackend(Map<String, dynamic> data) {
    final teamData = data['team'] as Map<String, dynamic>?;
    final trainingData = data['training'] as Map<String, dynamic>?;

    final dateString = data['date'] as String?;
    DateTime? sessionDate;
    if (dateString != null) {
      sessionDate = DateTime.tryParse(dateString);
    }

    return Training(
      id: data['id'] as String? ?? '',
      date: sessionDate,
      teamId: teamData?['id'] as String?,
      teamName:
          teamData?['abbreviation'] as String? ?? teamData?['name'] as String?,
      trainingId: trainingData?['id'] as String?,
      dayOfWeek: trainingData?['dayOfWeek'] != null
          ? DayOfWeek.fromBackend(trainingData!['dayOfWeek'] as String)
          : null,
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      location: data['location'] as String? ?? '',
      type: TrainingType.fromBackend(
        data['trainingType'] as String? ?? 'PHYSICAL',
      ),
      status: TrainingStatus.fromBackend(
        data['status'] as String? ?? 'UPCOMING',
      ),
      attendances: const [],
    );
  }

  Training _mapSessionDetailFromBackend(Map<String, dynamic> data) {
    final teamData = data['team'] as Map<String, dynamic>?;
    final trainingData = data['training'] as Map<String, dynamic>?;

    final dateString = data['date'] as String?;
    DateTime? sessionDate;
    if (dateString != null) {
      sessionDate = DateTime.tryParse(dateString);
    }

    final professorsData = (teamData?['professors'] as List<dynamic>?) ?? [];
    String? professorName;
    String? professorId;
    if (professorsData.isNotEmpty) {
      final firstProfessor = professorsData.first as Map<String, dynamic>;
      professorId = firstProfessor['id'] as String?;
      final personData = firstProfessor['person'] as Map<String, dynamic>?;
      if (personData != null) {
        final name = personData['name'] as String? ?? '';
        final surname = personData['surname'] as String? ?? '';
        professorName = '$name $surname'.trim();
      }
    }

    final playersData = (teamData?['players'] as List<dynamic>?) ?? [];
    final attendances = playersData.whereType<Map<String, dynamic>>().map((
      player,
    ) {
      final personData = player['person'] as Map<String, dynamic>?;
      final name = personData?['name'] as String? ?? '';
      final surname = personData?['surname'] as String? ?? '';

      final assistancesData = (player['assistances'] as List<dynamic>?) ?? [];
      bool isPresent = false;

      if (sessionDate != null && assistancesData.isNotEmpty) {
        for (final assistance in assistancesData) {
          final assistanceMap = assistance as Map<String, dynamic>;
          final assistanceDate = assistanceMap['date'] as String?;
          if (assistanceDate != null) {
            final parsedDate = DateTime.tryParse(assistanceDate);
            if (parsedDate != null &&
                parsedDate.year == sessionDate.year &&
                parsedDate.month == sessionDate.month &&
                parsedDate.day == sessionDate.day) {
              isPresent = assistanceMap['assistance'] as bool? ?? false;
              break;
            }
          }
        }
      }

      return PlayerAttendance(
        playerId: player['id'] as String? ?? '',
        playerName: '$name $surname'.trim(),
        isPresent: isPresent,
      );
    }).toList();

    return Training(
      id: data['id'] as String? ?? '',
      date: sessionDate,
      teamId: teamData?['id'] as String?,
      teamName:
          teamData?['abbreviation'] as String? ?? teamData?['name'] as String?,
      professorId: professorId,
      professorName: professorName,
      trainingId: trainingData?['id'] as String?,
      dayOfWeek: trainingData?['dayOfWeek'] != null
          ? DayOfWeek.fromBackend(trainingData!['dayOfWeek'] as String)
          : null,
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      location: data['location'] as String? ?? '',
      type: TrainingType.fromBackend(
        data['trainingType'] as String? ?? 'PHYSICAL',
      ),
      status: TrainingStatus.fromBackend(
        data['status'] as String? ?? 'UPCOMING',
      ),
      attendances: attendances,
    );
  }

  Training _mapTrainingFromBackend(Map<String, dynamic> data) {
    final teamData = data['team'] as Map<String, dynamic>?;
    final teamAbbreviation = teamData?['abbreviation'] as String?;

    final professorsData = (teamData?['professors'] as List<dynamic>?) ?? [];
    String? professorName;
    if (professorsData.isNotEmpty) {
      final firstProfessor = professorsData.first as Map<String, dynamic>;
      final personData = firstProfessor['person'] as Map<String, dynamic>?;
      if (personData != null) {
        final name = personData['name'] as String? ?? '';
        final surname = personData['surname'] as String? ?? '';
        professorName = '$name $surname'.trim();
      }
    }

    final playersData = (teamData?['players'] as List<dynamic>?) ?? [];
    final attendances = playersData
        .whereType<Map<String, dynamic>>()
        .map(
          (player) => PlayerAttendance(
            playerId: player['id'] as String? ?? '',
            playerName: '',
            isPresent: false,
          ),
        )
        .toList();

    return Training(
      id: data['id'] as String? ?? '',
      teamId: teamData?['id'] as String?,
      teamName: teamAbbreviation,
      professorId: null,
      professorName: professorName,
      dayOfWeek: data['dayOfWeek'] != null
          ? DayOfWeek.fromBackend(data['dayOfWeek'] as String)
          : null,
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      location: data['location'] as String? ?? '',
      type: TrainingType.fromBackend(
        data['trainingType'] as String? ?? 'PHYSICAL',
      ),
      status: TrainingStatus.proximo,
      attendances: attendances,
    );
  }
}
