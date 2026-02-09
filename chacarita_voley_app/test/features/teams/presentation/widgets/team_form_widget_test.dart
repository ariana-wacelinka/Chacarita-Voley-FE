import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/teams/presentation/widgets/team_form_widget.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/assistance.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/assistance_stats.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:chacarita_voley_app/features/users/domain/repositories/user_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUserRepository implements UserRepositoryInterface {
  bool? lastPlayerIsCompetitive;
  String? lastRole;
  String? lastSearchQuery;
  bool lastForTeamSelection = false;

  @override
  Future<List<User>> getUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
    bool? playerIsCompetitive,
    int? page,
    int? size,
    bool forTeamSelection = false,
  }) async {
    lastRole = role;
    lastSearchQuery = searchQuery;
    lastPlayerIsCompetitive = playerIsCompetitive;
    lastForTeamSelection = forTeamSelection;
    return [];
  }

  @override
  Future<int> getTotalUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
  }) async => 0;

  @override
  Future<User?> getUserById(String id) async => null;

  @override
  Future<User> createUser(User user) async => user;

  @override
  Future<User> updateUser(User user) async => user;

  @override
  Future<void> deleteUser(String id) async => Future.value();

  @override
  Future<AssistancePage> getAllAssistance({
    required String playerId,
    String? startTimeFrom,
    String? endTimeTo,
    required int page,
    required int size,
  }) async => throw UnimplementedError();

  @override
  Future<AssistanceStats> getAssistanceStatsByPlayerId(String playerId) async =>
      throw UnimplementedError();
}

Finder _playersSearchField() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.hintText == 'Buscar...',
  );
}

void main() {
  testWidgets(
    'competitive team search includes competitive and non-competitive players',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repo = FakeUserRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TeamFormWidget(onSubmit: (_) {}, userRepository: repo),
          ),
        ),
      );

      await tester.tap(find.text('Competitivo'));
      await tester.pumpAndSettle();

      expect(repo.lastRole, 'PLAYER');
      expect(repo.lastForTeamSelection, isTrue);
      expect(repo.lastPlayerIsCompetitive, isNull);
    },
  );

  testWidgets('recreativo team search filters non-competitive players', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = FakeUserRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TeamFormWidget(onSubmit: (_) {}, userRepository: repo),
        ),
      ),
    );

    await tester.tap(_playersSearchField());
    await tester.pumpAndSettle();

    expect(repo.lastRole, 'PLAYER');
    expect(repo.lastForTeamSelection, isTrue);
    expect(repo.lastPlayerIsCompetitive, isFalse);
  });
}
