import 'package:chacarita_voley_app/features/trainings/domain/entities/training.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Training entity', () {
    test('dateFormatted returns expected format', () {
      final training = Training(
        id: '1',
        teamId: '1',
        teamName: 'Equipo A',
        professorId: '4',
        professorName: 'Profesor 1',
        dayOfWeek: DayOfWeek.monday,
        startTime: '18:00',
        endTime: '19:00',
        location: 'Gimnasio Principal',
        type: TrainingType.fisico,
        status: TrainingStatus.proximo,
      );

      expect(training.dateFormatted, 'Lunes');
    });

    test('copyWith creates modified copy', () {
      final training = Training(
        id: '1',
        teamId: '1',
        teamName: 'Equipo A',
        professorId: '4',
        professorName: 'Profesor 1',
        dayOfWeek: DayOfWeek.tuesday,
        startTime: '18:00',
        endTime: '19:00',
        location: 'Gimnasio Principal',
        type: TrainingType.fisico,
        status: TrainingStatus.proximo,
      );

      final updated = training.copyWith(location: 'Cancha Exterior');

      expect(updated.location, 'Cancha Exterior');
      expect(updated.teamName, training.teamName);
      expect(updated.id, training.id);
    });

    test('totalPlayers falls back to attendances when countOfPlayers is zero', () {
      final attendances = [
        PlayerAttendance(
          playerId: '1',
          playerDni: '123',
          playerName: 'Jugador 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerDni: '456',
          playerName: 'Jugador 2',
          isPresent: false,
        ),
      ];

      final training = Training(
        id: '1',
        teamId: '1',
        teamName: 'Equipo A',
        professorId: '4',
        professorName: 'Profesor 1',
        dayOfWeek: DayOfWeek.monday,
        startTime: '18:00',
        endTime: '19:00',
        location: 'Gimnasio Principal',
        type: TrainingType.fisico,
        status: TrainingStatus.proximo,
        attendances: attendances,
        countOfPlayers: 0,
      );

      expect(training.totalPlayers, attendances.length);
    });

    test('presentCount falls back to attendances when countOfAssisted is zero', () {
      final attendances = [
        PlayerAttendance(
          playerId: '1',
          playerDni: '123',
          playerName: 'Jugador 1',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '2',
          playerDni: '456',
          playerName: 'Jugador 2',
          isPresent: true,
        ),
        PlayerAttendance(
          playerId: '3',
          playerDni: '789',
          playerName: 'Jugador 3',
          isPresent: false,
        ),
      ];

      final training = Training(
        id: '1',
        teamId: '1',
        teamName: 'Equipo A',
        professorId: '4',
        professorName: 'Profesor 1',
        dayOfWeek: DayOfWeek.monday,
        startTime: '18:00',
        endTime: '19:00',
        location: 'Gimnasio Principal',
        type: TrainingType.fisico,
        status: TrainingStatus.proximo,
        attendances: attendances,
        countOfAssisted: 0,
      );

      expect(training.presentCount, 2);
    });
  });
}
