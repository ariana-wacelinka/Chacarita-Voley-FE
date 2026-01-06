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
        date: DateTime(2025, 6, 16),
        startTime: '18:00',
        endTime: '19:00',
        location: 'Gimnasio Principal',
        type: TrainingType.fisico,
        status: TrainingStatus.proximo,
      );

      expect(training.dateFormatted, 'Lunes, 16 De Junio');
    });

    test('copyWith creates modified copy', () {
      final training = Training(
        id: '1',
        teamId: '1',
        teamName: 'Equipo A',
        professorId: '4',
        professorName: 'Profesor 1',
        date: DateTime(2025, 6, 16),
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
  });
}
