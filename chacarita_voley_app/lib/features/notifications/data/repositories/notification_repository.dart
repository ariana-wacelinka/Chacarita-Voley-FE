import '../../domain/entities/notification.dart';

class NotificationRepository {
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();

    return [
      NotificationModel(
        id: '1',
        title: 'Titulo generico',
        message: 'Se repite cada jueves',
        type: NotificationType.recordatorio,
        status: NotificationStatus.enviada,
        createdAt: now.subtract(const Duration(days: 2)),
        recipients: ['todos'],
        recipientsText: 'Todos los socios',
        startTime: '18:00',
      ),
      NotificationModel(
        id: '2',
        title: 'Titulo generico',
        message: 'Se repite cada jueves',
        type: NotificationType.aviso,
        status: NotificationStatus.enviada,
        createdAt: now.subtract(const Duration(days: 1)),
        recipients: ['equipo-1', 'equipo-2', 'equipo-3'],
        recipientsText: 'Equipo Masculino A',
        startTime: '18:00',
      ),
      NotificationModel(
        id: '3',
        title: 'Titulo generico',
        message: 'Información importante',
        type: NotificationType.general,
        status: NotificationStatus.programada,
        createdAt: now,
        scheduledFor: DateTime(2025, 6, 12),
        recipients: ['equipo-2', 'equipo-3', 'equipo-4', 'equipo-5'],
        recipientsText: 'Equipo Femenino B',
        startTime: '18:00',
      ),
      NotificationModel(
        id: '4',
        title: 'Titulo generico',
        message: 'Aviso general',
        type: NotificationType.urgente,
        status: NotificationStatus.enviada,
        createdAt: now.subtract(const Duration(hours: 3)),
        scheduledFor: DateTime(2025, 6, 12),
        recipients: ['equipo-1', 'equipo-2', 'equipo-3', 'equipo-4'],
        recipientsText: 'Todos los equipos',
        startTime: '18:00',
      ),
      NotificationModel(
        id: '5',
        title: 'Titulo generico',
        message: 'Recordatorio importante',
        type: NotificationType.recordatorio,
        status: NotificationStatus.borrador,
        createdAt: now,
        recipients: ['profesores'],
        recipientsText: 'Todos los profesores',
        startTime: '18:00',
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
