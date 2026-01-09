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
    return GraphQLClientFactory.withFreshClient(run: (c) => c.query(options));
  }

  Future<QueryResult> _mutate(MutationOptions options) {
    final override = _clientOverride;
    if (override != null) return override.mutate(options);
    return GraphQLClientFactory.withFreshClient(run: (c) => c.mutate(options));
  }

  static const String _trainingFields = r'''
    id
    dayOfWeek
    startTime
    endTime
    location
    trainingType
  ''';

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

  String _getAllTrainingsQuery() =>
      '''
    query GetAllTrainings {
      getAllTrainings {
        $_trainingFields
      }
    }
  ''';

  String _getTrainingByIdQuery() =>
      '''
    query GetTrainingById(\$id: ID!) {
      getTrainingById(id: \$id) {
        $_trainingFields
      }
    }
  ''';

  @override
  Future<List<Training>> getTrainings({
    DateTime? startDate,
    DateTime? endDate,
    String? teamId,
    TrainingStatus? status,
  }) async {
    final result = await _query(
      QueryOptions(
        document: gql(_getAllTrainingsQuery()),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final trainings =
        (result.data?['getAllTrainings'] as List<dynamic>?) ?? const [];

    return trainings
        .whereType<Map<String, dynamic>>()
        .map((data) => _mapTrainingFromBackend(data))
        .toList();
  }

  @override
  Future<Training?> getTrainingById(String id) async {
    final result = await _query(
      QueryOptions(
        document: gql(_getTrainingByIdQuery()),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['getTrainingById'] as Map<String, dynamic>?;
    if (data == null) return null;

    return _mapTrainingFromBackend(data);
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

  Training _mapTrainingFromBackend(Map<String, dynamic> data) {
    final attendancesData = data['attendances'] as List<dynamic>?;
    final attendances =
        attendancesData
            ?.map(
              (item) => PlayerAttendance(
                playerId: (item as Map)['playerId'] as String? ?? '',
                playerName: item['playerName'] as String? ?? '',
                isPresent: item['isPresent'] as bool? ?? false,
              ),
            )
            .toList() ??
        <PlayerAttendance>[];

    return Training(
      id: data['id'] as String? ?? '',
      teamId: data['teamId'] as String?,
      teamName: data['teamName'] as String?,
      professorId: data['professorId'] as String?,
      professorName: data['professorName'] as String?,
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
