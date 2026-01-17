import '../../domain/entities/notification.dart';

class NotificationRepository {
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();

    return [
      NotificationModel(
        id: '1',
        title: 'Pago de cuota',
        message: 'Recordatorio para el pago de la cuota mensual',
        sendMode: SendMode.SCHEDULED,
        createdAt: now.subtract(const Duration(days: 2)),
        scheduledAt: DateTime(now.year, now.month, 1, 9, 0),
        repeatable: true,
        frequency: Frequency.MONTHLY,
        destinations: [
          NotificationDestination(
            id: '1',
            referenceId: null,
            type: DestinationType.DUES_PENDING,
          ),
        ],
        deliveries: [],
      ),
      NotificationModel(
        id: '2',
        title: 'Entrenamiento cancelado',
        message: 'El entrenamiento del jueves ha sido cancelado',
        sendMode: SendMode.IMMEDIATE,
        createdAt: now.subtract(const Duration(days: 1)),
        scheduledAt: null,
        repeatable: false,
        frequency: null,
        destinations: [
          NotificationDestination(
            id: '2',
            referenceId: 'team-1',
            type: DestinationType.TEAM,
          ),
        ],
        deliveries: [
          NotificationDelivery(
            id: '1',
            recipientId: 'user-1',
            status: DeliveryStatus.DELIVERED,
            attemptedAt: now.subtract(const Duration(days: 1, hours: 2)),
            sentAt: now.subtract(const Duration(days: 1, hours: 2)),
          ),
        ],
      ),
      NotificationModel(
        id: '3',
        title: 'Reunión de equipo',
        message: 'Reunión importante este viernes a las 19:00',
        sendMode: SendMode.SCHEDULED,
        createdAt: now,
        scheduledAt: DateTime(now.year, now.month, now.day + 2, 18, 0),
        repeatable: true,
        frequency: Frequency.WEEKLY,
        destinations: [
          NotificationDestination(
            id: '3',
            referenceId: null,
            type: DestinationType.ALL,
          ),
        ],
        deliveries: [],
      ),
      NotificationModel(
        id: '4',
        title: 'Cuotas vencidas',
        message: 'Tienes cuotas pendientes de pago',
        sendMode: SendMode.SCHEDULED,
        createdAt: now.subtract(const Duration(hours: 3)),
        scheduledAt: DateTime(now.year, now.month, 15, 10, 0),
        repeatable: true,
        frequency: Frequency.WEEKLY,
        destinations: [
          NotificationDestination(
            id: '4',
            referenceId: null,
            type: DestinationType.DUES_OVERDUE,
          ),
        ],
        deliveries: [],
      ),
      NotificationModel(
        id: '5',
        title: 'Actualización de horarios',
        message: 'Se han actualizado los horarios de entrenamiento',
        sendMode: SendMode.IMMEDIATE,
        createdAt: now,
        scheduledAt: null,
        repeatable: false,
        frequency: null,
        destinations: [
          NotificationDestination(
            id: '5',
            referenceId: 'team-2',
            type: DestinationType.TEAM,
          ),
          NotificationDestination(
            id: '6',
            referenceId: 'team-3',
            type: DestinationType.TEAM,
          ),
        ],
        deliveries: [],
      ),
    ];
  }

  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return notification;
  }
}
