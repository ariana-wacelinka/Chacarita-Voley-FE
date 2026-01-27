import '../../../users/domain/entities/user.dart' show EstadoCuota;

enum TrainingType {
  fisico('PHYSICAL'),
  pelota('BALL_SKILLS');

  final String backendValue;
  const TrainingType(this.backendValue);

  String get displayName {
    switch (this) {
      case TrainingType.fisico:
        return 'Físico';
      case TrainingType.pelota:
        return 'Pelota';
    }
  }

  static TrainingType fromBackend(String value) {
    switch (value) {
      case 'PHYSICAL':
        return TrainingType.fisico;
      case 'BALL_SKILLS':
        return TrainingType.pelota;
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
  saturday('SATURDAY'),
  sunday('SUNDAY');

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
      case DayOfWeek.sunday:
        return 'Domingo';
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
      case 'SUNDAY':
        return DayOfWeek.sunday;
      default:
        return DayOfWeek.monday;
    }
  }
}

enum TrainingStatus {
  proximo('UPCOMING'),
  enCurso('IN_PROGRESS'),
  completado('COMPLETED'),
  cancelado('CANCELLED');

  final String backendValue;
  const TrainingStatus(this.backendValue);

  String get displayName {
    switch (this) {
      case TrainingStatus.proximo:
        return 'Próximo';
      case TrainingStatus.enCurso:
        return 'En curso';
      case TrainingStatus.completado:
        return 'Completado';
      case TrainingStatus.cancelado:
        return 'Cancelado';
    }
  }

  static TrainingStatus fromBackend(String value) {
    switch (value) {
      case 'UPCOMING':
        return TrainingStatus.proximo;
      case 'IN_PROGRESS':
        return TrainingStatus.enCurso;
      case 'COMPLETED':
        return TrainingStatus.completado;
      case 'CANCELLED':
        return TrainingStatus.cancelado;
      default:
        return TrainingStatus.proximo;
    }
  }
}

class PlayerAttendance {
  final String playerId;
  final String playerName;
  final bool isPresent;
  final EstadoCuota? estadoCuota;

  PlayerAttendance({
    required this.playerId,
    required this.playerName,
    required this.isPresent,
    this.estadoCuota,
  });

  PlayerAttendance copyWith({
    String? playerId,
    String? playerName,
    bool? isPresent,
    EstadoCuota? estadoCuota,
  }) {
    return PlayerAttendance(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      isPresent: isPresent ?? this.isPresent,
      estadoCuota: estadoCuota ?? this.estadoCuota,
    );
  }
}

class Training {
  final String id;
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? teamId;
  final String? teamName;
  final String? professorId;
  final String? professorName;
  final DayOfWeek? dayOfWeek;
  final List<DayOfWeek>? daysOfWeek;
  final String startTime;
  final String endTime;
  final String location;
  final TrainingType type;
  final TrainingStatus status;
  final List<PlayerAttendance> attendances;
  final String? trainingId;
  final bool hasTraining;
  final int? countOfPlayers;
  final int? countOfAssisted;

  Training({
    required this.id,
    this.date,
    this.startDate,
    this.endDate,
    this.teamId,
    this.teamName,
    this.professorId,
    this.professorName,
    this.dayOfWeek,
    this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    required this.status,
    this.attendances = const [],
    this.trainingId,
    this.hasTraining = true,
    this.countOfPlayers,
    this.countOfAssisted,
  });

  int get totalPlayers => countOfPlayers ?? attendances.length;
  int get presentCount =>
      countOfAssisted ?? attendances.where((a) => a.isPresent).length;
  int get absentCount => totalPlayers - presentCount;

  String get dateFormatted {
    if (date != null) {
      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${date!.day} ${months[date!.month - 1]} ${date!.year}';
    }
    return dayOfWeek?.displayName ?? 'Sin día asignado';
  }

  String get startTimeFormatted {
    if (startTime.contains(':')) {
      final parts = startTime.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    }
    return startTime;
  }

  String get endTimeFormatted {
    if (endTime.contains(':')) {
      final parts = endTime.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    }
    return endTime;
  }

  Training copyWith({
    String? id,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? teamId,
    String? teamName,
    String? professorId,
    String? professorName,
    DayOfWeek? dayOfWeek,
    List<DayOfWeek>? daysOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    TrainingType? type,
    TrainingStatus? status,
    List<PlayerAttendance>? attendances,
    String? trainingId,
    int? countOfPlayers,
    int? countOfAssisted,
  }) {
    return Training(
      id: id ?? this.id,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      professorId: professorId ?? this.professorId,
      professorName: professorName ?? this.professorName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      attendances: attendances ?? this.attendances,
      trainingId: trainingId ?? this.trainingId,
      countOfPlayers: countOfPlayers ?? this.countOfPlayers,
      countOfAssisted: countOfAssisted ?? this.countOfAssisted,
    );
  }
}
