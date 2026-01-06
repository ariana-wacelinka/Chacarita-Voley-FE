import '../../domain/entities/training.dart';
import '../../domain/repositories/training_repository_interface.dart';

class TrainingRepository implements TrainingRepositoryInterface {
  static final List<Training> _trainings = [
    Training(
      id: '1',
      teamId: '1',
      teamName: 'Equipo A',
      professorId: '4',
      professorName: 'Profesor 1',
      date: DateTime(2025, 6, 14),
      startTime: '18:00',
      endTime: '19:00',
      location: 'Gimnasio Principal',
      type: TrainingType.fisico,
      status: TrainingStatus.proximo,
      attendances: [
        PlayerAttendance(
          playerId: '1',
          playerName: 'Jugador 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerName: 'Jugador 2',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '3',
          playerName: 'Jugador 3',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '4',
          playerName: 'Jugador 4',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '5',
          playerName: 'Jugador 5',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '6',
          playerName: 'Jugador 6',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '7',
          playerName: 'Jugador 7',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '8',
          playerName: 'Jugador 8',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '9',
          playerName: 'Jugador 9',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '10',
          playerName: 'Jugador 10',
          isPresent: false,
        ),
      ],
    ),
    Training(
      id: '2',
      teamId: '1',
      teamName: 'Equipo A',
      professorId: '4',
      professorName: 'Profesor 1',
      date: DateTime(2025, 6, 16),
      startTime: '18:00',
      endTime: '19:00',
      location: 'Gimnasio Principal',
      type: TrainingType.tecnico,
      status: TrainingStatus.proximo,
      attendances: [
        PlayerAttendance(
          playerId: '1',
          playerName: 'Jugador 1',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '2',
          playerName: 'Jugador 2',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '3',
          playerName: 'Jugador 3',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '4',
          playerName: 'Jugador 4',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '5',
          playerName: 'Jugador 5',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '6',
          playerName: 'Jugador 6',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '7',
          playerName: 'Jugador 7',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '8',
          playerName: 'Jugador 8',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '9',
          playerName: 'Jugador 9',
          isPresent: false,
        ),
        PlayerAttendance(
          playerId: '10',
          playerName: 'Jugador 10',
          isPresent: false,
        ),
      ],
    ),
    Training(
      id: '3',
      teamId: '1',
      teamName: 'Equipo A',
      professorId: '4',
      professorName: 'Profesor 1',
      date: DateTime(2025, 6, 10),
      startTime: '18:00',
      endTime: '19:00',
      location: 'Cancha Exterior',
      type: TrainingType.partido,
      status: TrainingStatus.completado,
      attendances: [
        PlayerAttendance(
          playerId: '1',
          playerName: 'Jugador 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerName: 'Jugador 2',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '3',
          playerName: 'Jugador 3',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '4',
          playerName: 'Jugador 4',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '5',
          playerName: 'Jugador 5',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '6',
          playerName: 'Jugador 6',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '7',
          playerName: 'Jugador 7',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '8',
          playerName: 'Jugador 8',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '9',
          playerName: 'Jugador 9',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '10',
          playerName: 'Jugador 10',
          isPresent: true,
        ),
      ],
    ),
    // Entrenamientos de ejemplo para equipos reales del backend
    Training(
      id: '4',
      teamId: '165',
      teamName: 'Chaca Feme',
      professorId: '4',
      professorName: 'Profesor 1',
      date: DateTime(2025, 6, 20),
      startTime: '19:00',
      endTime: '20:30',
      location: 'Gimnasio Principal',
      type: TrainingType.tecnico,
      status: TrainingStatus.proximo,
      attendances: [
        PlayerAttendance(
          playerId: '1',
          playerName: 'Jugadora 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerName: 'Jugadora 2',
          isPresent: false,
        ),
      ],
    ),
    Training(
      id: '5',
      teamId: '166',
      teamName: 'Chaca Blanco',
      professorId: '4',
      professorName: 'Profesor 1',
      date: DateTime(2025, 6, 22),
      startTime: '18:30',
      endTime: '20:00',
      location: 'Cancha Exterior',
      type: TrainingType.fisico,
      status: TrainingStatus.proximo,
      attendances: [
        PlayerAttendance(
          playerId: '1',
          playerName: 'Jugador 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerName: 'Jugador 2',
          isPresent: true,
        ),
      ],
    ),
    Training(
      id: '6',
      teamId: '168',
      teamName: 'Chaca Rojo',
      professorId: '4',
      professorName: 'Profesor 1',
      date: DateTime(2025, 6, 24),
      startTime: '19:30',
      endTime: '21:00',
      location: 'Gimnasio Principal',
      type: TrainingType.partido,
      status: TrainingStatus.proximo,
      attendances: [
        PlayerAttendance(
          playerId: '1',
          playerName: 'Jugador 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerName: 'Jugador 2',
          isPresent: false,
        ),
      ],
    ),
    Training(
      id: '7',
      teamId: '172',
      teamName: 'Chaca Negro',
      professorId: '4',
      professorName: 'Profesor 1',
      date: DateTime(2025, 6, 26),
      startTime: '20:00',
      endTime: '21:30',
      location: 'Cancha Exterior',
      type: TrainingType.tecnico,
      status: TrainingStatus.proximo,
      attendances: [
        PlayerAttendance(
          playerId: '1',
          playerName: 'Jugador 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerName: 'Jugador 2',
          isPresent: true,
        ),
      ],
    ),
  ];

  @override
  Future<List<Training>> getTrainings({
    DateTime? startDate,
    DateTime? endDate,
    String? teamId,
    TrainingStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = List<Training>.from(_trainings);

    if (startDate != null) {
      filtered = filtered
          .where(
            (t) => t.date.isAfter(startDate.subtract(const Duration(days: 1))),
          )
          .toList();
    }

    if (endDate != null) {
      filtered = filtered
          .where((t) => t.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    }

    if (teamId != null) {
      filtered = filtered.where((t) => t.teamId == teamId).toList();
    }

    if (status != null) {
      filtered = filtered.where((t) => t.status == status).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  @override
  Future<Training?> getTrainingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _trainings.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Training> createTraining(Training training) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = (_trainings.length + 1).toString();
    final newTraining = training.copyWith(id: newId);
    _trainings.add(newTraining);
    return newTraining;
  }

  @override
  Future<Training> updateTraining(Training training) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _trainings.indexWhere((t) => t.id == training.id);
    if (index != -1) {
      _trainings[index] = training;
      return training;
    }
    throw Exception('Entrenamiento no encontrado');
  }

  @override
  Future<void> deleteTraining(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _trainings.removeWhere((t) => t.id == id);
  }

  @override
  Future<Training> updateAttendance(
    String trainingId,
    List<PlayerAttendance> attendances,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _trainings.indexWhere((t) => t.id == trainingId);
    if (index != -1) {
      final updated = _trainings[index].copyWith(attendances: attendances);
      _trainings[index] = updated;
      return updated;
    }
    throw Exception('Entrenamiento no encontrado');
  }
}
