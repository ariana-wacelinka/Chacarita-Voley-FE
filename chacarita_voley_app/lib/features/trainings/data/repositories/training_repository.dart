import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../../../users/domain/entities/due.dart' show DueState;
import '../../../users/domain/entities/user.dart'
    show EstadoCuota, EstadoCuotaExtension;
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

  static const String _addTrainingsToTeamMutation = r'''
    mutation AddTrainingsToTeam($teamId: ID!, $dayOfWeek: [DayOfWeek!]!, $startTime: String!, $endTime: String!, $trainingType: TrainingType!, $location: String!, $startDate: String!, $endDate: String!) {
      addTrainingsToTeam(
        teamId: $teamId
        trainingInputs: {
          dayOfWeek: $dayOfWeek
          startTime: $startTime
          endTime: $endTime
          trainingType: $trainingType
          location: $location
          startDate: $startDate
          endDate: $endDate
        }
      ) {
        id
        dayOfWeek
        startTime
        endTime
        location
        trainingType
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
      }
    }
  ''';

  static const String _createTrainingMutation = _addTrainingsToTeamMutation;

  static const String _updateTrainingMutation = r'''
    mutation UpdateTraining($id: ID!, $dayOfWeek: DayOfWeek!, $startTime: String!, $endTime: String!, $trainingType: TrainingType!, $location: String!, $startDate: String, $endDate: String) {
      updateTraining(id: $id, input: {dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, trainingType: $trainingType, location: $location, startDate: $startDate, endDate: $endDate}) {
        id
        dayOfWeek
        startTime
        endTime
        location
        trainingType
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
      }
    }
  ''';

  static const String _updateSessionMutation = r'''
    mutation UpdateSession($id: ID!, $trainingType: TrainingType!, $startTime: String!, $endTime: String!, $location: String!, $date: String!) {
      updateSession(id: $id, input: {trainingType: $trainingType, startTime: $startTime, endTime: $endTime, location: $location, date: $date}) {
        id
        date
        startTime
        endTime
        location
        trainingType
        status
      }
    }
  ''';

  static const String _deleteTrainingMutation = r'''
    mutation DeleteTraining($id: ID!) {
      deleteTraining(id: $id)
    }
  ''';

  static const String _deleteSessionMutation = r'''
    mutation DeleteSession($id: ID!) {
      deleteSession(id: $id)
    }
  ''';

  static const String _cancelSessionMutation = r'''
    mutation CancelSession($id: ID!) {
      cancelSession(id: $id) {
        id
      }
    }
  ''';

  static const String _reactivateSessionMutation = r'''
    mutation ReactivateSession($id: ID!) {
      reactivateSession(id: $id) {
        id
      }
    }
  ''';

  String _getAllSessionsQuery({
    String? dateFrom,
    String? dateTo,
    String? startTimeFrom,
    String? startTimeTo,
    String? statusValue,
    String? teamId,
    String? playerId,
  }) =>
      '''
    query GetAllSessions(\$page: Int!, \$size: Int!) {
      getAllSessions(page: \$page, size: \$size, filters: {dateFrom: "${dateFrom ?? ''}", dateTo: "${dateTo ?? ''}", startTimeFrom: "${startTimeFrom ?? ''}", startTimeTo: "${startTimeTo ?? ''}", statuses: ${statusValue ?? 'null'}, teamId: "${teamId ?? ''}", playerId: "${playerId ?? ''}"}) {
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
          countOfPlayers
          countOfAssisted
          team {
            id
            abbreviation
            players {
              id
            }
            professors {
              person {
                name
                surname
              }
            }
          }
          training {
            id
            dayOfWeek
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
            currentDue {
              id
              state
            }
          }
        }
        training {
          id
          dayOfWeek
          trainingType
          startTime
          endTime
          location
          startDate
          endDate
        }
      }
    }
  ''';

  Future<Map<String, dynamic>> getTrainingsWithPagination({
    String? dateFrom,
    String? dateTo,
    String? startTimeFrom,
    String? startTimeTo,
    TrainingStatus? status,
    String? teamId,
    String? playerId,
    int page = 0,
    int size = 10,
  }) async {
    final result = await _query(
      QueryOptions(
        document: gql(
          _getAllSessionsQuery(
            dateFrom: dateFrom,
            dateTo: dateTo,
            startTimeFrom: startTimeFrom,
            startTimeTo: startTimeTo,
            statusValue: status?.backendValue,
            teamId: teamId,
            playerId: playerId,
          ),
        ),
        variables: {'page': page, 'size': size},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final sessionsData = result.data?['getAllSessions'];
    if (sessionsData == null) {
      return {
        'content': <Training>[],
        'totalPages': 0,
        'totalElements': 0,
        'pageNumber': 0,
        'hasNext': false,
        'hasPrevious': false,
      };
    }

    final content = (sessionsData['content'] as List<dynamic>?) ?? const [];
    final trainings = content
        .whereType<Map<String, dynamic>>()
        .map((data) => _mapSessionFromBackend(data))
        .toList();

    return {
      'content': trainings,
      'totalPages': sessionsData['totalPages'] as int? ?? 0,
      'totalElements': sessionsData['totalElements'] as int? ?? 0,
      'pageNumber': sessionsData['pageNumber'] as int? ?? 0,
      'hasNext': sessionsData['hasNext'] as bool? ?? false,
      'hasPrevious': sessionsData['hasPrevious'] as bool? ?? false,
    };
  }

  @override
  Future<List<Training>> getTrainings({
    DateTime? startDate,
    DateTime? endDate,
    String? teamId,
    TrainingStatus? status,
    int page = 0,
    int size = 10,
  }) async {
    // Convertir DateTime a String formato YYYY-MM-DD si están presentes
    String? dateFrom;
    String? dateTo;

    if (startDate != null) {
      dateFrom =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }

    if (endDate != null) {
      dateTo =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }

    final result = await getTrainingsWithPagination(
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
      page: page,
      size: size,
    );
    return result['content'] as List<Training>;
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
    if (training.teamId == null || training.teamId!.isEmpty) {
      throw Exception('teamId es requerido para crear un training');
    }

    String startDate;
    String endDate;

    if (training.startDate != null && training.endDate != null) {
      startDate = training.startDate!.toIso8601String().split('T')[0];
      endDate = training.endDate!.toIso8601String().split('T')[0];
    } else if (training.date != null) {
      startDate = training.date!.toIso8601String().split('T')[0];
      endDate = training.date!.toIso8601String().split('T')[0];
    } else {
      final now = DateTime.now();
      final dayOfWeekValue =
          training.dayOfWeek?.backendValue ??
          training.daysOfWeek?.first.backendValue ??
          'MONDAY';

      final dayOfWeekMap = {
        'MONDAY': DateTime.monday,
        'TUESDAY': DateTime.tuesday,
        'WEDNESDAY': DateTime.wednesday,
        'THURSDAY': DateTime.thursday,
        'FRIDAY': DateTime.friday,
        'SATURDAY': DateTime.saturday,
        'SUNDAY': DateTime.sunday,
      };

      final targetWeekday = dayOfWeekMap[dayOfWeekValue] ?? DateTime.monday;
      final daysUntilTarget = (targetWeekday - now.weekday) % 7;
      final nextOccurrence = now.add(
        Duration(days: daysUntilTarget == 0 ? 7 : daysUntilTarget),
      );

      startDate = nextOccurrence.toIso8601String().split('T')[0];
      endDate = nextOccurrence
          .add(const Duration(days: 365))
          .toIso8601String()
          .split('T')[0];
    }

    final daysToCreate =
        training.daysOfWeek ??
        (training.dayOfWeek != null
            ? [training.dayOfWeek!]
            : [DayOfWeek.monday]);

    final daysOfWeekValues = daysToCreate.map((d) => d.backendValue).toList();

    final variables = {
      'teamId': training.teamId,
      'dayOfWeek': daysOfWeekValues,
      'startTime': training.startTime,
      'endTime': training.endTime,
      'trainingType': training.type.backendValue,
      'location': training.location,
      'startDate': startDate,
      'endDate': endDate,
    };

    final result = await _mutate(
      MutationOptions(
        document: gql(_createTrainingMutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final dataList = result.data?['addTrainingsToTeam'] as List<dynamic>?;
    if (dataList == null || dataList.isEmpty) {
      throw Exception('No se recibieron trainings del backend');
    }
    final firstTraining = dataList.first as Map<String, dynamic>;
    final createdTraining = _mapTrainingFromBackend(firstTraining);
    return createdTraining;
  }

  @override
  Future<Training> updateTraining(Training training) async {
    final trainingId = training.trainingId ?? training.id;

    final variables = {
      'id': trainingId,
      'dayOfWeek': training.dayOfWeek?.backendValue ?? 'MONDAY',
      'startTime': training.startTime,
      'endTime': training.endTime,
      'trainingType': training.type.backendValue,
      'location': training.location,
      'startDate': training.startDate?.toIso8601String().split('T')[0],
      'endDate': training.endDate?.toIso8601String().split('T')[0],
    };

    final result = await _mutate(
      MutationOptions(
        document: gql(_updateTrainingMutation),
        variables: variables,
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

  Future<Training> updateSession(Training session) async {
    final variables = {
      'id': session.id,
      'trainingType': session.type.backendValue,
      'startTime': session.startTime,
      'endTime': session.endTime,
      'location': session.location,
      'date': session.date?.toIso8601String().split('T')[0],
    };

    final result = await _mutate(
      MutationOptions(
        document: gql(_updateSessionMutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['updateSession'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Respuesta inválida de updateSession');
    }

    final updatedSession = await getTrainingById(session.id);
    if (updatedSession == null) {
      throw Exception('No se pudo recargar la sesión');
    }

    return updatedSession;
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

  Future<void> deleteSession(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_deleteSessionMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> cancelSession(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_cancelSessionMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  Future<void> reactivateSession(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_reactivateSessionMutation),
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
    // Construir la lista de inputs como strings para la mutación
    final inputListString = attendances
        .map(
          (attendance) =>
              '{assistance: ${attendance.isPresent}, playerId: "${attendance.playerId}", sessionId: "$trainingId"}',
        )
        .join(', ');
    // Construir la mutación con los valores inline
    final mutation =
        '''
      mutation CreateAssistance {
        createAssistance(inputList: [$inputListString]) {
          id
          assistance
          date
          player {
            id
            person {
              name
              surname
            }
          }
        }
      }
    ''';

    final result = await _mutate(MutationOptions(document: gql(mutation)));

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    // Recargar el training actualizado
    final updatedTraining = await getTrainingById(trainingId);
    if (updatedTraining == null) {
      throw Exception('No se pudo recargar el entrenamiento');
    }

    return updatedTraining;
  }

  Training _mapSessionFromBackend(Map<String, dynamic> data) {
    final teamData = data['team'] as Map<String, dynamic>?;
    final trainingData = data['training'] as Map<String, dynamic>?;

    final dateString = data['date'] as String?;
    DateTime? sessionDate;
    if (dateString != null) {
      sessionDate = DateTime.tryParse(dateString);
    }

    final professorsData = (teamData?['professors'] as List<dynamic>?) ?? [];
    String? professorName;
    if (professorsData.isNotEmpty) {
      final firstProfessor = professorsData.first as Map<String, dynamic>;
      final personData = firstProfessor['person'] as Map<String, dynamic>?;
      if (personData != null) {
        final name = personData['name'] as String? ?? '';
        final surname = personData['surname'] as String? ?? '';
        professorName = '$surname $name'.trim();
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
      date: sessionDate,
      teamId: teamData?['id'] as String?,
      teamName: teamData?['abbreviation'] as String?,
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
      hasTraining: trainingData != null,
      countOfPlayers: data['countOfPlayers'] as int?,
      countOfAssisted: data['countOfAssisted'] as int?,
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
        professorName = '$surname $name'.trim();
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

      EstadoCuota? estadoCuota;
      final currentDueData = player['currentDue'] as Map<String, dynamic>?;
      if (currentDueData != null) {
        final stateString = currentDueData['state'] as String?;
        if (stateString != null) {
          final dueState = DueState.values.firstWhere(
            (e) => e.name == stateString,
            orElse: () => DueState.PENDING,
          );
          estadoCuota = EstadoCuotaExtension.fromDueState(dueState);
        }
      }

      return PlayerAttendance(
        playerId: player['id'] as String? ?? '',
        playerName: '$surname $name'.trim(),
        isPresent: isPresent,
        estadoCuota: estadoCuota,
      );
    }).toList();

    // Parse startDate and endDate from training
    DateTime? trainingStartDate;
    DateTime? trainingEndDate;

    if (trainingData?['startDate'] != null) {
      trainingStartDate = DateTime.tryParse(
        trainingData!['startDate'] as String,
      );
    }

    if (trainingData?['endDate'] != null) {
      trainingEndDate = DateTime.tryParse(trainingData!['endDate'] as String);
    }

    return Training(
      id: data['id'] as String? ?? '',
      date: sessionDate,
      startDate: trainingStartDate,
      endDate: trainingEndDate,
      teamId: teamData?['id'] as String?,
      teamName:
          teamData?['abbreviation'] as String? ?? teamData?['name'] as String?,
      professorId: professorId,
      professorName: professorName,
      trainingId: trainingData?['id'] as String?,
      dayOfWeek: trainingData?['dayOfWeek'] != null
          ? DayOfWeek.fromBackend(trainingData!['dayOfWeek'] as String)
          : null,
      startTime: trainingData?['startTime'] as String? ?? '',
      endTime: trainingData?['endTime'] as String? ?? '',
      location: trainingData?['location'] as String? ?? '',
      type: TrainingType.fromBackend(
        trainingData?['trainingType'] as String? ?? 'PHYSICAL',
      ),
      status: TrainingStatus.fromBackend(
        data['status'] as String? ?? 'UPCOMING',
      ),
      attendances: attendances,
      hasTraining: trainingData != null,
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
        professorName = '$surname $name'.trim();
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
      status: TrainingStatus.fromBackend(
        data['status'] as String? ?? 'UPCOMING',
      ),
      attendances: attendances,
    );
  }
}
