import 'package:chacarita_voley_app/features/trainings/data/repositories/training_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingRepository getAllSessions query', () {
    test('includes professorId filter when provided', () {
      final repository = TrainingRepository();
      final query = repository.buildGetAllSessionsQuery(
        professorId: '1',
        statusValue: 'UPCOMING',
      );

      expect(query, contains('professorId: "1"'));
      expect(query, contains('statuses: UPCOMING'));
    });

    test('includes training fields for list', () {
      final repository = TrainingRepository();
      final query = repository.buildGetAllSessionsQuery();

      expect(query, contains('training {'));
      expect(query, contains('trainingType'));
      expect(query, contains('startDate'));
      expect(query, contains('endDate'));
      expect(query, contains('isDeleted'));
    });

    test('includes isDeleted filter when show deleted is enabled', () {
      final repository = TrainingRepository();
      final query = repository.buildGetAllSessionsQuery(includeDeleted: true);

      expect(query, contains('isDeleted: true'));
    });
  });

  test('getAllAssistance by session query uses sessionId variable', () {
    final repository = TrainingRepository();
    final query = repository.buildGetAllAssistanceBySessionQuery();

    expect(query, contains('getAllAssistance'));
    expect(query, contains('sessionId: \$sessionId'));
  });
}
