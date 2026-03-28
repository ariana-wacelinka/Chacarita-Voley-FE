import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/core/services/auth_service.dart';
import 'package:chacarita_voley_app/features/teams/data/repositories/team_repository.dart';
import 'package:chacarita_voley_app/features/teams/domain/entities/team.dart';
import 'package:chacarita_voley_app/features/teams/domain/entities/team_type.dart';
import 'package:chacarita_voley_app/features/teams/presentation/pages/view_team_page.dart';
import 'package:chacarita_voley_app/features/users/data/repositories/user_repository.dart';

class _FakeTeamRepository extends TeamRepository {
  _FakeTeamRepository(this.team) : super();

  final Team team;

  @override
  Future<Team?> getTeamById(String id, {bool includeDeleted = false}) async {
    return team;
  }
}

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository() : super();

  String? lastUpdatedPersonId;
  Map<String, dynamic>? lastUpdateInput;

  @override
  Future<void> updatePerson(String personId, Map<String, dynamic> input) async {
    lastUpdatedPersonId = personId;
    lastUpdateInput = input;
  }
}

class _FakeAuthService extends AuthService {
  _FakeAuthService(this.roles);

  final List<String> roles;

  @override
  Future<List<String>?> getUserRoles() async => roles;

  @override
  Future<int?> getUserId() async => 42;
}

Team _buildTeam() {
  return Team(
    id: 'team-1',
    nombre: 'Equipo A',
    abreviacion: 'EA',
    tipo: TeamType.competitivo,
    integrantes: [
      TeamMember(
        playerId: 'player-1',
        personId: 'person-1',
        dni: '12345678',
        nombre: 'Juan',
        apellido: 'Pérez',
        numeroAfiliado: '10',
        numeroCamiseta: '7',
      ),
    ],
  );
}

void main() {
  testWidgets(
    'Integrantes menu: abre dialog de datos competitivos y permite editar camiseta',
    (tester) async {
      final teamRepository = _FakeTeamRepository(_buildTeam());
      final userRepository = _FakeUserRepository();
      final authService = _FakeAuthService(['ADMIN']);

      final router = GoRouter(
        initialLocation: '/teams/1',
        routes: [
          GoRoute(
            path: '/teams/:id',
            builder: (_, state) => ViewTeamPage(
              teamId: state.pathParameters['id']!,
              repository: teamRepository,
              userRepository: userRepository,
              authService: authService,
            ),
          ),
          GoRoute(
            path: '/users/:id/view',
            builder: (_, state) => Scaffold(
              body: Text('USER_VIEW_PAGE_${state.pathParameters['id']}'),
            ),
          ),
          GoRoute(
            path: '/users/:id/edit',
            builder: (_, state) => const Scaffold(body: Text('USER_EDIT_PAGE')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router, theme: AppTheme.light),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Symbols.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver datos competitivos'));
      await tester.pumpAndSettle();
      expect(find.text('Datos del Jugador Competitivo'), findsOneWidget);
      expect(find.text('Camiseta'), findsWidgets);

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Symbols.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Modificar datos competitivos'));
      await tester.pumpAndSettle();

      final field = find.byKey(const Key('competitive-jersey-number-field'));
      expect(field, findsOneWidget);
      await tester.enterText(field, '99');

      await tester.tap(find.byKey(const Key('competitive-save-button')));
      await tester.pumpAndSettle();

      expect(find.text('99'), findsWidgets);
      expect(userRepository.lastUpdatedPersonId, 'person-1');
      expect(userRepository.lastUpdateInput?['jerseyNumber'], 99);
    },
  );

  testWidgets('Integrantes menu: navegar a visualizar jugador', (tester) async {
    final teamRepository = _FakeTeamRepository(_buildTeam());
    final userRepository = _FakeUserRepository();
    final authService = _FakeAuthService(['ADMIN']);

    final router = GoRouter(
      initialLocation: '/teams/1',
      routes: [
        GoRoute(
          path: '/teams/:id',
          builder: (_, state) => ViewTeamPage(
            teamId: state.pathParameters['id']!,
            repository: teamRepository,
            userRepository: userRepository,
            authService: authService,
          ),
        ),
        GoRoute(
          path: '/users/:id/view',
          builder: (_, state) => Scaffold(
            body: Text('USER_VIEW_PAGE_${state.pathParameters['id']}'),
          ),
        ),
        GoRoute(
          path: '/users/:id/edit',
          builder: (_, __) => const Scaffold(body: Text('USER_EDIT_PAGE')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.more_vert).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Visualizar jugador'));
    await tester.pumpAndSettle();

    expect(find.text('USER_VIEW_PAGE_person-1'), findsOneWidget);
  });
}
