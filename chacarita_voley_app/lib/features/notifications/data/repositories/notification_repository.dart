import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../../domain/entities/notification.dart';

class NotificationRepository {
  Future<QueryResult> _query(QueryOptions options) {
    return GraphQLClientFactory.client.query(options);
  }

  Future<QueryResult> _mutate(MutationOptions options) {
    return GraphQLClientFactory.client.mutate(options);
  }

  String _getAllNotificationsQuery() =>
      '''
    query GetAllNotifications(\$page: Int!, \$size: Int!) {
      getAllNotifications(page: \$page, size: \$size) {
        totalPages
        totalElements
        pageSize
        pageNumber
        hasNext
        hasPrevious
        content {
          id
          title
          scheduledAt
          repeatable
          frequency
          destinations {
            id
          }
        }
      }
    }
  ''';

  Future<NotificationPageResult> getNotifications({
    int page = 0,
    int size = 10,
  }) async {
    final result = await _query(
      QueryOptions(
        document: gql(_getAllNotificationsQuery()),
        variables: {
          'page': page,
          'size': size,
        },
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final notificationsData = result.data?['getAllNotifications'];
    if (notificationsData == null) {
      return NotificationPageResult(
        notifications: [],
        totalPages: 0,
        totalElements: 0,
        currentPage: page,
        hasNext: false,
        hasPrevious: false,
      );
    }

    final content = (notificationsData['content'] as List<dynamic>?) ?? const [];
    final notifications = content
        .whereType<Map<String, dynamic>>()
        .map((data) => _mapNotificationFromBackend(data))
        .toList();

    return NotificationPageResult(
      notifications: notifications,
      totalPages: notificationsData['totalPages'] as int? ?? 0,
      totalElements: notificationsData['totalElements'] as int? ?? 0,
      currentPage: notificationsData['pageNumber'] as int? ?? page,
      hasNext: notificationsData['hasNext'] as bool? ?? false,
      hasPrevious: notificationsData['hasPrevious'] as bool? ?? false,
    );
  }

  NotificationModel _mapNotificationFromBackend(Map<String, dynamic> data) {
    // Parsear scheduledAt
    DateTime? scheduledAt;
    final scheduledAtStr = data['scheduledAt'] as String?;
    if (scheduledAtStr != null && scheduledAtStr.isNotEmpty) {
      try {
        scheduledAt = DateTime.parse(scheduledAtStr);
      } catch (e) {
        // Si falla el parsing, usar null
        scheduledAt = null;
      }
    }

    // Mapear frequency
    Frequency? frequency;
    final frequencyStr = data['frequency'] as String?;
    if (frequencyStr != null) {
      switch (frequencyStr) {
        case 'DAILY':
          frequency = Frequency.DAILY;
          break;
        case 'WEEKLY':
          frequency = Frequency.WEEKLY;
          break;
        case 'BIWEEKLY':
          frequency = Frequency.BIWEEKLY;
          break;
        case 'MONTHLY':
          frequency = Frequency.MONTHLY;
          break;
      }
    }

    // Mapear destinations
    final destinationsData = (data['destinations'] as List<dynamic>?) ?? [];
    final destinations = destinationsData
        .whereType<Map<String, dynamic>>()
        .map(
          (dest) => NotificationDestination(
            id: dest['id'] as String? ?? '',
            referenceId: null, // No disponible en la query actual
            type: DestinationType.ALL_PLAYERS, // Default, se puede mejorar
          ),
        )
        .toList();

    return NotificationModel(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: '', // No disponible en la query actual
      sendMode: scheduledAt != null ? SendMode.SCHEDULED : SendMode.NOW,
      createdAt: DateTime.now(), // No disponible en la query actual
      scheduledAt: scheduledAt,
      repeatable: data['repeatable'] as bool? ?? false,
      frequency: frequency,
      destinations: destinations,
      deliveries: [], // No disponible en la query actual
    );
  }

  Future<void> deleteNotification(String id) async {
    // TODO: Implementar mutation de delete cuando esté disponible
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    // TODO: Implementar mutation de create cuando esté disponible
    await Future.delayed(const Duration(milliseconds: 500));
    return notification;
  }
}

class NotificationPageResult {
  final List<NotificationModel> notifications;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;

  NotificationPageResult({
    required this.notifications,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
  });
}
