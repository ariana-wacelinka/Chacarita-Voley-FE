import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/core/services/auth_service.dart';
import 'package:chacarita_voley_app/features/teams/data/repositories/team_repository.dart';
import 'package:chacarita_voley_app/features/teams/domain/entities/team_list_item.dart';
import 'package:chacarita_voley_app/features/teams/domain/entities/team_type.dart';
import 'package:chacarita_voley_app/features/teams/presentation/pages/teams_page.dart';
import 'package:chacarita_voley_app/features/users/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class _FakeTeamRepository extends TeamRepository {
  _FakeTeamRepository() : super();

  bool? lastIncludeDeleted;
  String? restoredTeamId;

  final List<TeamListItem> _activeTeams = [
    TeamListItem(
      id: 'team-active',
      nombre: 'Equipo Activo',
      abreviacion: 'EA',
      tipo: TeamType.competitivo,
      cantidadJugadores: 12,
      entrenadores: const ['Coach Activo'],
    ),
  ];

  final List<TeamListItem> _deletedTeams = [
    TeamListItem(
      id: 'team-deleted',
      nombre: 'Equipo Eliminado',
      abreviacion: 'EE',
      tipo: TeamType.recreativo,
      cantidadJugadores: 8,
      entrenadores: const ['Coach Eliminado'],
      isDeleted: true,
    ),
  ];

  @override
  Future<List<TeamListItem>> getTeamsListItems({
    String? searchQuery,
    String? professorId,
    bool? isCompetitive,
    String? playerId,
    int? page,
    int? size,
    bool includeDeleted = false,
  }) async {
    lastIncludeDeleted = includeDeleted;
    return includeDeleted ? _deletedTeams : _activeTeams;
  }

  @override
  Future<int> getTotalTeams({
    String? searchQuery,
    String? professorId,
    bool? isCompetitive,
    String? playerId,
    bool includeDeleted = false,
  }) async {
    return includeDeleted ? _deletedTeams.length : _activeTeams.length;
  }

  @override
  Future<void> restoreTeam(String id) async {
    restoredTeamId = id;
    _deletedTeams.removeWhere((team) => team.id == id);
  }
}

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository() : super();
}

class _FakeAuthService extends AuthService {
  _FakeAuthService(this.roles);

  final List<String> roles;

  @override
  Future<List<String>?> getUserRoles() async => roles;

  @override
  Future<int?> getUserId() async => 1;
}

void main() {
  testWidgets('teams page allows showing and restoring deleted teams', (
    tester,
  ) async {
    final repository = _FakeTeamRepository();
    final userRepository = _FakeUserRepository();
    final authService = _FakeAuthService(['ADMIN']);

    final router = GoRouter(
      initialLocation: '/teams',
      routes: [
        GoRoute(
          path: '/teams',
          builder: (_, __) => TeamsPage(
            repository: repository,
            userRepository: userRepository,
            authService: authService,
          ),
        ),
        GoRoute(
          path: '/teams/view/:id',
          builder: (_, state) =>
              Scaffold(body: Text('VIEW_${state.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/teams/edit/:id',
          builder: (_, state) =>
              Scaffold(body: Text('EDIT_${state.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/teams/register',
          builder: (_, __) => const Scaffold(body: Text('REGISTER')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();

    expect(repository.lastIncludeDeleted, false);
    expect(find.text('Mostrar eliminados'), findsOneWidget);

    await tester.tap(find.text('Mostrar eliminados'));
    await tester.pumpAndSettle();

    expect(repository.lastIncludeDeleted, true);
    expect(find.text('Eliminado'), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurar'));
    await tester.pumpAndSettle();

    expect(find.text('Restaurar equipo'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Restaurar'));
    await tester.pumpAndSettle();

    expect(repository.restoredTeamId, 'team-deleted');
  });
}
