enum TrainingType {
  fisico('PHYSICAL'),
  tecnico('BALL_SKILLS'),
  tactico('TACTICAL'),
  partido('MATCH');

  final String backendValue;
  const TrainingType(this.backendValue);

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

  static TrainingType fromBackend(String value) {
    switch (value) {
      case 'PHYSICAL':
        return TrainingType.fisico;
      case 'BALL_SKILLS':
        return TrainingType.tecnico;
      case 'TACTICAL':
        return TrainingType.tactico;
      case 'MATCH':
        return TrainingType.partido;
      default:
        return TrainingType.fisico;
    }
  }
}

enum DayOfWeek {
  monday('MONDAY'),
  tuesday('TUESDAY'),
  wednesday('WEDNESDAY'),
  thursday('THURSDAY'),
  friday('FRIDAY'),
  saturday('SATURDAY');

  final String backendValue;
  const DayOfWeek(this.backendValue);

  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Lunes';
      case DayOfWeek.tuesday:
        return 'Martes';
      case DayOfWeek.wednesday:
        return 'Miércoles';
      case DayOfWeek.thursday:
        return 'Jueves';
      case DayOfWeek.friday:
        return 'Viernes';
      case DayOfWeek.saturday:
        return 'Sábado';
    }
  }

  static DayOfWeek fromBackend(String value) {
    switch (value) {
      case 'MONDAY':
        return DayOfWeek.monday;
      case 'TUESDAY':
        return DayOfWeek.tuesday;
      case 'WEDNESDAY':
        return DayOfWeek.wednesday;
      case 'THURSDAY':
        return DayOfWeek.thursday;
      case 'FRIDAY':
        return DayOfWeek.friday;
      case 'SATURDAY':
        return DayOfWeek.saturday;
      default:
        return DayOfWeek.monday;
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
  final String? teamId;
  final String? teamName;
  final String? professorId;
  final String? professorName;
  final DayOfWeek? dayOfWeek;
  final String startTime;
  final String endTime;
  final String location;
  final TrainingType type;
  final TrainingStatus status;
  final List<PlayerAttendance> attendances;

  Training({
    required this.id,
    this.teamId,
    this.teamName,
    this.professorId,
    this.professorName,
    this.dayOfWeek,
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
    return dayOfWeek?.displayName ?? 'Sin día asignado';
  }

  Training copyWith({
    String? id,
    String? teamId,
    String? teamName,
    String? professorId,
    String? professorName,
    DayOfWeek? dayOfWeek,
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
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      attendances: attendances ?? this.attendances,
    );
  }
}
