import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/core/network/graphql_client_factory.dart';
import 'package:chacarita_voley_app/features/teams/presentation/pages/view_team_page.dart';

void main() {
  setUpAll(() {
    GraphQLClientFactory.init(baseUrl: 'https://example.com/graphql');
  });

  testWidgets(
    'Integrantes menu: abre dialog de datos competitivos y permite editar camiseta',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/teams/1',
        routes: [
          GoRoute(
            path: '/teams/:id',
            builder: (_, state) =>
                ViewTeamPage(teamId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/users/:id/view',
            builder: (_, state) => const Scaffold(body: Text('USER_VIEW_PAGE')),
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

      // Esperar la carga del equipo hardcodeado (usa Future.delayed).
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();

      // Abrir menú del primer integrante.
      await tester.tap(find.byIcon(Symbols.more_vert).first);
      await tester.pumpAndSettle();

      // Ver datos competitivos.
      await tester.tap(find.text('Ver datos competitivos'));
      await tester.pumpAndSettle();
      expect(find.text('Datos competitivos'), findsOneWidget);
      expect(find.textContaining('Número de camiseta:'), findsOneWidget);

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      // Modificar datos competitivos.
      await tester.tap(find.byIcon(Symbols.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Modificar datos competitivos'));
      await tester.pumpAndSettle();

      final field = find.byKey(const Key('competitive-jersey-number-field'));
      expect(field, findsOneWidget);
      await tester.enterText(field, '99');

      await tester.tap(find.byKey(const Key('competitive-save-button')));
      await tester.pumpAndSettle();

      // La tabla debería reflejar el nuevo número.
      expect(find.text('99'), findsWidgets);
    },
  );

  testWidgets('Integrantes menu: navegar a visualizar jugador', (tester) async {
    final router = GoRouter(
      initialLocation: '/teams/1',
      routes: [
        GoRoute(
          path: '/teams/:id',
          builder: (_, state) =>
              ViewTeamPage(teamId: state.pathParameters['id']!),
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

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Symbols.more_vert).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Visualizar jugador'));
    await tester.pumpAndSettle();

    expect(find.text('USER_VIEW_PAGE_12345678'), findsOneWidget);
  });
}
