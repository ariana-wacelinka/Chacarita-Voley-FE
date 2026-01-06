enum TrainingType {
  fisico,
  tecnico,
  tactico,
  partido;

  String get displayName {
    switch (this) {
      case TrainingType.fisico:
        return 'Físico';
      case TrainingType.tecnico:
        return 'Técnico';
      case TrainingType.tactico:
        return 'Táctico';
      case TrainingType.partido:
        return 'Partido';
    }
  }
}

enum TrainingStatus {
  proximo,
  completado,
  cancelado;

  String get displayName {
    switch (this) {
      case TrainingStatus.proximo:
        return 'Próximo';
      case TrainingStatus.completado:
        return 'Completado';
      case TrainingStatus.cancelado:
        return 'Cancelado';
    }
  }
}

class PlayerAttendance {
  final String playerId;
  final String playerName;
  final bool isPresent;

  PlayerAttendance({
    required this.playerId,
    required this.playerName,
    required this.isPresent,
  });

  PlayerAttendance copyWith({
    String? playerId,
    String? playerName,
    bool? isPresent,
  }) {
    return PlayerAttendance(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}

class Training {
  final String id;
  final String teamId;
  final String teamName;
  final String professorId;
  final String professorName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final TrainingType type;
  final TrainingStatus status;
  final List<PlayerAttendance> attendances;

  Training({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.professorId,
    required this.professorName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    required this.status,
    this.attendances = const [],
  });

  int get totalPlayers => attendances.length;
  int get presentCount => attendances.where((a) => a.isPresent).length;
  int get absentCount => attendances.where((a) => !a.isPresent).length;

  String get dateFormatted {
    final weekdays = [
      '',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${weekdays[date.weekday]}, ${date.day} De ${months[date.month]}';
  }

  Training copyWith({
    String? id,
    String? teamId,
    String? teamName,
    String? professorId,
    String? professorName,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? location,
    TrainingType? type,
    TrainingStatus? status,
    List<PlayerAttendance>? attendances,
  }) {
    return Training(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      professorId: professorId ?? this.professorId,
      professorName: professorName ?? this.professorName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      attendances: attendances ?? this.attendances,
    );
  }
}
