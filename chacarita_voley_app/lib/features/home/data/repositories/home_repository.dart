import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/models/home_stats.dart';
import '../../domain/models/notification_preview.dart';
import '../../domain/models/training_preview.dart';
import '../../../../core/network/graphql_client_factory.dart';

class HomeRepository {
  HomeRepository({GraphQLClient? graphQLClient})
    : _clientOverride = graphQLClient;

  final GraphQLClient? _clientOverride;

  Future<QueryResult> _query(QueryOptions options) {
    final override = _clientOverride;
    if (override != null) return override.query(options);
    return GraphQLClientFactory.client.query(options);
  }

  Future<HomeStats> getStats() async {
    const String query = r'''
      query GetStats {
        getStats {
          totalTrainingToday
          totalScheduledNotifications
          totalOverdueDues
          totalMembers
        }
      }
    ''';

    try {
      final result = await _query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('Error al obtener estadísticas: ${result.exception}');
      }

      final data = result.data?['getStats'];
      if (data == null) {
        return HomeStats.empty();
      }

      return HomeStats.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  Future<List<NotificationPreview>> getScheduledNotifications() async {
    const String query = r'''
      query GetScheduledNotifications {
        getAllNotifications(page: 0, size: 3, filters: {status: SCHEDULED}) {
          content {
            id
            title
          }
        }
      }
    ''';

    try {
      print('🔵 Ejecutando query de notificaciones...');
      final result = await _query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      print('🔵 Result hasException: ${result.hasException}');
      if (result.hasException) {
        print('🔴 Exception: ${result.exception}');
        return [];
      }

      print('🔵 Result data: ${result.data}');
      final content = result.data?['getAllNotifications']?['content'] as List?;
      print('🔵 Content: $content');

      if (content == null) {
        print('🔴 Content es null');
        return [];
      }

      final notifications = content
          .map(
            (json) =>
                NotificationPreview.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      print('🟢 Notificaciones parseadas: ${notifications.length}');
      return notifications;
    } catch (e, stackTrace) {
      print('🔴 Error en getScheduledNotifications: $e');
      print('🔴 StackTrace: $stackTrace');
      return [];
    }
  }

  Future<List<TrainingPreview>> getTodayTrainings() async {
    // Obtener fecha actual en hora argentina (UTC-3)
    final now = DateTime.now().toUtc().add(const Duration(hours: -3));
    final todayDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    print('🔵 DateTime.now(): ${DateTime.now()}');
    print('🔵 DateTime.now().toUtc(): ${DateTime.now().toUtc()}');
    print('🔵 Hora Argentina calculada: $now');
    print('🔵 Fecha formateada para query: $todayDate');

    final query =
        '''
      query GetTodayTrainings {
        getAllSessions(
          page: 0
          size: 10
          filters: {dateFrom: "$todayDate", dateTo: "$todayDate"}
        ) {
          content {
            id
            startTime
            endTime
            status
            team {
              id
              name
              players {
                id
                assistances {
                  id
                  assistance
                  date
                  player {
                    id
                  }
                }
              }
              professors {
                person {
                  id
                  name
                  surname
                }
              }
            }
          }
        }
      }
    ''';

    try {
      print('🔵 Ejecutando query de entrenamientos del día: $todayDate');
      print('🔵 Query completa:\n$query');
      final result = await _query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      print('🔵 Result hasException: ${result.hasException}');
      if (result.hasException) {
        print('🔴 Exception: ${result.exception}');
        return [];
      }

      print('🔵 Result data: ${result.data}');
      final content = result.data?['getAllSessions']?['content'] as List?;
      print('🔵 Content length: ${content?.length ?? 0}');
      print('🔵 Content raw: $content');

      if (content == null || content.isEmpty) {
        print('🔴 Content es null o está vacío');
        return [];
      }

      print('🔵 Parseando ${content.length} sesiones...');
      final trainings = content.map((json) {
        print('🔵 JSON de sesión: $json');
        return TrainingPreview.fromJson(
          json as Map<String, dynamic>,
          todayDate,
        );
      }).toList();

      print('🟢 Entrenamientos del día parseados: ${trainings.length}');
      for (var training in trainings) {
        print(
          '  - ${training.teamName} a las ${training.formattedTime} (${training.attendance}/${training.totalPlayers})',
        );
      }
      return trainings;
    } catch (e, stackTrace) {
      print('🔴 Error en getTodayTrainings: $e');
      print('🔴 StackTrace: $stackTrace');
      return [];
    }
  }
}
