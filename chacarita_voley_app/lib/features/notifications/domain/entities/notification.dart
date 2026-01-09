enum NotificationType {
  general,
  recordatorio,
  aviso,
  urgente;

  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.recordatorio:
        return 'Recordatorio';
      case NotificationType.aviso:
        return 'Aviso';
      case NotificationType.urgente:
        return 'Urgente';
    }
  }
}

enum NotificationStatus {
  enviada,
  programada,
  borrador;

  String get displayName {
    switch (this) {
      case NotificationStatus.enviada:
        return 'Enviada';
      case NotificationStatus.programada:
        return 'Programada';
      case NotificationStatus.borrador:
        return 'Borrador';
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final List<String> recipients;
  final String recipientsText;
  final String startTime;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
    this.scheduledFor,
    required this.recipients,
    required this.recipientsText,
    required this.startTime,
  });
}
