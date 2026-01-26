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

enum SendMode {
  NOW,
  SCHEDULED;

  String get displayName {
    switch (this) {
      case SendMode.NOW:
        return 'Envío inmediato';
      case SendMode.SCHEDULED:
        return 'Programado';
    }
  }

  static SendMode fromString(String value) {
    return SendMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SendMode.NOW,
    );
  }
}

enum Frequency {
  DAILY,
  WEEKLY,
  MONTHLY;

  String get displayName {
    switch (this) {
      case Frequency.DAILY:
        return 'Diaria';
      case Frequency.WEEKLY:
        return 'Semanal';
      case Frequency.MONTHLY:
        return 'Mensual';
    }
  }

  static Frequency fromString(String value) {
    return Frequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Frequency.WEEKLY,
    );
  }

  static Frequency fromSpanish(String spanish) {
    switch (spanish) {
      case 'Diaria':
        return Frequency.DAILY;
      case 'Semanal':
        return Frequency.WEEKLY;
      case 'Mensual':
        return Frequency.MONTHLY;
      default:
        return Frequency.WEEKLY;
    }
  }
}

enum DestinationType {
  PLAYER,
  TEAM,
  ALL_PLAYERS,
  DUES_PENDING,
  DUES_OVERDUE;

  String get displayName {
    switch (this) {
      case DestinationType.PLAYER:
        return 'Jugador';
      case DestinationType.TEAM:
        return 'Equipo';
      case DestinationType.ALL_PLAYERS:
        return 'Todos los jugadores';
      case DestinationType.DUES_PENDING:
        return 'Cuota pendiente';
      case DestinationType.DUES_OVERDUE:
        return 'Cuota vencida';
    }
  }

  static DestinationType fromString(String value) {
    return DestinationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DestinationType.ALL_PLAYERS,
    );
  }
}

enum DeliveryStatus {
  PENDING,
  SENT,
  FAILED,
  DELIVERED;

  String get displayName {
    switch (this) {
      case DeliveryStatus.PENDING:
        return 'Pendiente';
      case DeliveryStatus.SENT:
        return 'Enviado';
      case DeliveryStatus.FAILED:
        return 'Fallido';
      case DeliveryStatus.DELIVERED:
        return 'Entregado';
    }
  }

  static DeliveryStatus fromString(String value) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeliveryStatus.PENDING,
    );
  }
}

class NotificationDestination {
  final String id;
  final String? referenceId;
  final DestinationType type;

  NotificationDestination({
    required this.id,
    this.referenceId,
    required this.type,
  });

  factory NotificationDestination.fromJson(Map<String, dynamic> json) {
    return NotificationDestination(
      id: json['id'] as String,
      referenceId: json['referenceId'] as String?,
      type: DestinationType.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'referenceId': referenceId, 'type': type.name};
  }
}

class NotificationDelivery {
  final String id;
  final String recipientId;
  final DeliveryStatus status;
  final DateTime? attemptedAt;
  final DateTime? sentAt;

  NotificationDelivery({
    required this.id,
    required this.recipientId,
    required this.status,
    this.attemptedAt,
    this.sentAt,
  });

  factory NotificationDelivery.fromJson(Map<String, dynamic> json) {
    return NotificationDelivery(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      status: DeliveryStatus.fromString(json['status'] as String),
      attemptedAt: json['attemptedAt'] != null
          ? DateTime.parse(json['attemptedAt'] as String)
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'status': status.name,
      'attemptedAt': attemptedAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
    };
  }
}

class NotificationSender {
  final String id;
  final String name;
  final String surname;
  final String dni;

  NotificationSender({
    required this.id,
    required this.name,
    required this.surname,
    required this.dni,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      dni: json['dni'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'surname': surname, 'dni': dni};
  }

  String get fullName => '$surname $name';
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final SendMode sendMode;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool repeatable;
  final Frequency? frequency;
  final List<NotificationDestination> destinations;
  final List<NotificationDelivery> deliveries;
  final int countOfPlayers;
  final NotificationSender? sender;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.sendMode,
    required this.createdAt,
    this.scheduledAt,
    required this.repeatable,
    this.frequency,
    required this.destinations,
    required this.deliveries,
    this.countOfPlayers = 0,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      sendMode: SendMode.fromString(json['sendMode'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      repeatable: json['repeatable'] as bool,
      frequency: json['frequency'] != null
          ? Frequency.fromString(json['frequency'] as String)
          : null,
      destinations: (json['destinations'] as List<dynamic>)
          .map(
            (d) => NotificationDestination.fromJson(d as Map<String, dynamic>),
          )
          .toList(),
      deliveries: (json['deliveries'] as List<dynamic>)
          .map((d) => NotificationDelivery.fromJson(d as Map<String, dynamic>))
          .toList(),
      countOfPlayers: json['countOfPlayers'] as int? ?? 0,
      sender: json['sender'] != null
          ? NotificationSender.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'sendMode': sendMode.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'repeatable': repeatable,
      'frequency': frequency?.name,
      'destinations': destinations.map((d) => d.toJson()).toList(),
      'deliveries': deliveries.map((d) => d.toJson()).toList(),
      'countOfPlayers': countOfPlayers,
      if (sender != null) 'sender': sender!.toJson(),
    };
  }

  // Helper methods
  String get startTime {
    if (scheduledAt != null) {
      return '${scheduledAt!.hour.toString().padLeft(2, '0')}:${scheduledAt!.minute.toString().padLeft(2, '0')}';
    }
    // If no scheduledAt, show createdAt time for NOW mode
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String getRepeatText() {
    if (!repeatable || frequency == null) {
      return '';
    }

    switch (frequency!) {
      case Frequency.DAILY:
        return 'Se repite cada día';
      case Frequency.WEEKLY:
        return 'Se repite todas las semanas';
      case Frequency.MONTHLY:
        return 'Se repite cada mes';
    }
  }

  String get recipientsText {
    if (destinations.isEmpty) return 'Sin destinatarios';

    if (destinations.length == 1) {
      return destinations.first.type.displayName;
    }

    return '${destinations.length} grupos de destinatarios';
  }
}

class NotificationListResponse {
  final List<NotificationModel> content;
  final int totalElements;
  final int totalPages;
  final int pageNumber;
  final int pageSize;
  final bool hasPrevious;
  final bool hasNext;

  NotificationListResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      content: (json['content'] as List<dynamic>)
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      hasPrevious: json['hasPrevious'] as bool,
      hasNext: json['hasNext'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((n) => n.toJson()).toList(),
      'totalElements': totalElements,
      'totalPages': totalPages,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'hasPrevious': hasPrevious,
      'hasNext': hasNext,
    };
  }
}
