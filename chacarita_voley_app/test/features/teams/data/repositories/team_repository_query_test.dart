import 'package:chacarita_voley_app/features/teams/data/repositories/team_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamRepository getAllTeams query', () {
    test('includes professorId filter', () {
      final repository = TeamRepository();
      final query = repository.buildGetAllTeamsQuery();

      expect(query, contains('professorId: \$professorId'));
      expect(query, contains('isDeleted: \$isDeleted'));
      expect(query, contains('isDeleted'));
    });

    test('includes isDeleted variable when show deleted is enabled', () {
      final repository = TeamRepository();
      final query = repository.buildGetAllTeamsQuery();

      expect(query, contains('\$isDeleted: Boolean'));
    });
  });
}
