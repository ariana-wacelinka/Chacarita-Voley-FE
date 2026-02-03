import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/models/home_stats.dart';
import '../../domain/models/notification_preview.dart';
import '../../domain/models/training_preview.dart';
import '../../domain/models/delivery_preview.dart';
import '../../domain/models/deliveries_page.dart';
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

  Future<List<TrainingPreview>> getPlayerTrainings(String playerId) async {
    // Obtener fecha actual y 6 días adelante en hora argentina (UTC-3)
    final now = DateTime.now().toUtc().add(const Duration(hours: -3));
    final sixDaysLater = now.add(const Duration(days: 6));

    final dateFrom =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final dateTo =
        '${sixDaysLater.year}-${sixDaysLater.month.toString().padLeft(2, '0')}-${sixDaysLater.day.toString().padLeft(2, '0')}';

    final query =
        '''
      query GetPlayerTrainings {
        getAllSessions(
          page: 0
          size: 20
          filters: {playerId: "$playerId", dateFrom: "$dateFrom", dateTo: "$dateTo"}
        ) {
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

      print(
        '🔍 DEBUG: getPlayerTrainings recibió ${content.length} entrenamientos',
      );

      final trainings = content.map((json) {
        final dateString = json['date'] as String?;
        return TrainingPreview.fromJson(
          json as Map<String, dynamic>,
          dateString ?? '',
        );
      }).toList();

      print(
        '🔍 DEBUG: getPlayerTrainings parseó ${trainings.length} entrenamientos',
      );

      return trainings;
    } catch (e) {
      return [];
    }
  }

  Future<List<DeliveryPreview>> getPlayerDeliveries(String personId) async {
    // Obtener fecha actual y hace 7 días en hora argentina (UTC-3)
    final now = DateTime.now().toUtc().add(const Duration(hours: -3));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final sentTo =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final sentFrom =
        '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}';

    final query =
        '''
      query GetPlayerDeliveries {
        getAllDeliveries(
          page: 0
          size: 10
          filters: {recipientId: "$personId", sentFrom: "$sentFrom", sentTo: "$sentTo", status: SENT}
        ) {
          content {
            id
            notification {
              title
              message
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

      final content = result.data?['getAllDeliveries']?['content'] as List?;

      if (content == null || content.isEmpty) {
        return [];
      }

      final deliveries = content
          .map((json) => DeliveryPreview.fromJson(json as Map<String, dynamic>))
          .toList();

      return deliveries;
    } catch (e) {
      return [];
    }
  }

  Future<DeliveriesPage> getUserDeliveries({
    required String personId,
    int page = 0,
    int size = 10,
  }) async {
    final query =
        '''
      query GetUserDeliveries {
        getAllDeliveries(
          page: $page
          size: $size
          filters: {recipientId: "$personId", sentFrom: "", sentTo: "", status: SENT}
        ) {
          totalPages
          totalElements
          pageSize
          pageNumber
          hasPrevious
          hasNext
          content {
            id
            notification {
              title
              message
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
        return DeliveriesPage.empty();
      }

      final data = result.data?['getAllDeliveries'] as Map<String, dynamic>?;

      if (data == null) {
        return DeliveriesPage.empty();
      }

      return DeliveriesPage.fromJson(data);
    } catch (e) {
      return DeliveriesPage.empty();
    }
  }
}
