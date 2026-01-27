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
      final result = await _query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      final content = result.data?['getAllNotifications']?['content'] as List?;

      if (content == null) {
        return [];
      }

      final notifications = content
          .map(
            (json) =>
                NotificationPreview.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return notifications;
    } catch (e) {
      return [];
    }
  }

  Future<List<TrainingPreview>> getTodayTrainings() async {
    // Obtener fecha actual en hora argentina (UTC-3)
    final now = DateTime.now().toUtc().add(const Duration(hours: -3));
    final todayDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

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
      final result = await _query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return [];
      }

      final content = result.data?['getAllSessions']?['content'] as List?;

      if (content == null || content.isEmpty) {
        return [];
      }

      final trainings = content.map((json) {
        return TrainingPreview.fromJson(
          json as Map<String, dynamic>,
          todayDate,
        );
      }).toList();
      return trainings;

    } catch (e) {
      return [];
    }
  }
}
