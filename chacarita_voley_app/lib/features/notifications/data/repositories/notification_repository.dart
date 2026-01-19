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

  String _getAllNotificationsQuery() => '''
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
          message
          sendMode
          scheduledAt
          repeatable
          frequency
          createdAt
          destinations {
            id
            type
            referenceId
          }
          deliveries {
            id
            status
            sentAt
            recipientId
            attemptedAt
          }
        }
      }
    }
  ''';

  Future<NotificationPageResult> getNotifications({
    int page = 0,
    int size = 10,
  }) async {
    print('📤 getNotifications called with page=$page, size=$size');

    final result = await _query(
      QueryOptions(
        document: gql(_getAllNotificationsQuery()),
        variables: {'page': page, 'size': size},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
    );

    print('📥 Query result: hasException=${result.hasException}');

    if (result.hasException) {
      print('❌ Exception: ${result.exception}');
      throw Exception(result.exception.toString());
    }

    print('📥 Raw data: ${result.data}');

    final notificationsData = result.data?['getAllNotifications'];
    if (notificationsData == null) {
      print('⚠️ notificationsData is null');
      return NotificationPageResult(
        notifications: [],
        totalPages: 0,
        totalElements: 0,
        currentPage: page,
        hasNext: false,
        hasPrevious: false,
      );
    }

    final content =
        (notificationsData['content'] as List<dynamic>?) ?? const [];
    print('📋 Content length: ${content.length}');

    final notifications = content
        .whereType<Map<String, dynamic>>()
        .map((data) => _mapNotificationFromBackend(data))
        .toList();

    print('✅ Mapped ${notifications.length} notifications');

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
    DateTime? scheduledAt;
    final scheduledAtStr = data['scheduledAt'] as String?;
    if (scheduledAtStr != null && scheduledAtStr.isNotEmpty) {
      try {
        scheduledAt = DateTime.parse(scheduledAtStr);
      } catch (e) {
        scheduledAt = null;
      }
    }

    DateTime createdAt = DateTime.now();
    final createdAtStr = data['createdAt'] as String?;
    if (createdAtStr != null && createdAtStr.isNotEmpty) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (e) {
        createdAt = DateTime.now();
      }
    }

    Frequency? frequency;
    final frequencyStr = data['frequency'] as String?;
    if (frequencyStr != null) {
      frequency = Frequency.fromString(frequencyStr);
    }

    SendMode sendMode = SendMode.NOW;
    final sendModeStr = data['sendMode'] as String?;
    if (sendModeStr != null) {
      sendMode = SendMode.fromString(sendModeStr);
    }

    final destinationsData = (data['destinations'] as List<dynamic>?) ?? [];
    final destinations = destinationsData
        .whereType<Map<String, dynamic>>()
        .map(
          (dest) => NotificationDestination(
            id: dest['id'] as String? ?? '',
            referenceId: dest['referenceId'] as String?,
            type: DestinationType.fromString(
              dest['type'] as String? ?? 'ALL_PLAYERS',
            ),
          ),
        )
        .toList();

    final deliveriesData = (data['deliveries'] as List<dynamic>?) ?? [];
    final deliveries = deliveriesData
        .whereType<Map<String, dynamic>>()
        .map((del) => NotificationDelivery.fromJson(del))
        .toList();

    return NotificationModel(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      sendMode: sendMode,
      createdAt: createdAt,
      scheduledAt: scheduledAt,
      repeatable: data['repeatable'] as bool? ?? false,
      frequency: frequency,
      destinations: destinations,
      deliveries: deliveries,
    );
  }

  Future<NotificationModel> createNotification({
    required String title,
    required String message,
    required SendMode sendMode,
    String? time,
    String? date,
    Frequency? frequency,
    required List<NotificationDestinationInput> destinations,
  }) async {
    final destinationsInput = destinations.map((d) {
      final dest = {'notificationDestinationType': d.type.name};
      if (d.referenceId != null) {
        dest['referenceId'] = d.referenceId!;
      }
      return dest;
    }).toList();

    final input = {
      'title': title,
      'message': message,
      'notificationSendMode': sendMode.name,
      'destinations': destinationsInput,
    };

    if (time != null && time.isNotEmpty) {
      input['time'] = time;
    }

    if (date != null && date.isNotEmpty) {
      input['date'] = date;
    }

    if (frequency != null) {
      input['frequency'] = frequency.name;
    }

    final mutation = '''
      mutation CreateNotification(\$input: CreateNotificationInput!) {
        createNotification(input: \$input) {
          id
          title
          message
          sendMode
          scheduledAt
          repeatable
          frequency
          createdAt
          destinations {
            id
            type
            referenceId
          }
          deliveries {
            id
            status
            sentAt
            recipientId
            attemptedAt
          }
        }
      }
    ''';

    final result = await _mutate(
      MutationOptions(document: gql(mutation), variables: {'input': input}),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final notificationData = result.data?['createNotification'];
    if (notificationData == null) {
      throw Exception('No se pudo crear la notificación');
    }

    return _mapNotificationFromBackend(
      notificationData as Map<String, dynamic>,
    );
  }

  Future<void> deleteNotification(String id) async {
    // TODO: Implementar mutation de delete cuando esté disponible
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

class NotificationDestinationInput {
  final DestinationType type;
  final String? referenceId;

  NotificationDestinationInput({required this.type, this.referenceId});
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
