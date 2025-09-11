import 'package:go_router/go_router.dart';
import 'layout/app_scaffold.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final title = _titleForLocation(state.uri.path);
        return AppScaffold(title: title, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (_, __) => const _Page(text: 'Inicio'),
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          builder: (_, __) => const _Page(text: 'Jugadores'),
        ),
        GoRoute(
          path: '/payments',
          name: 'payments',
          builder: (_, __) => const _Page(text: 'Pagos'),
        ),
        GoRoute(
          path: '/teams',
          name: 'teams',
          builder: (_, __) => const _Page(text: 'Equipos'),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (_, __) => const _Page(text: 'Notificaciones'),
        ),
      ],
    ),
  ],
);

String _titleForLocation(String loc) {
  const map = {
    '/': 'Inicio',
    '/users': 'Jugadores',
    '/payments': 'Pagos',
    '/teams': 'Equipos',
    '/notifications': 'Notificaciones',
  };
  return map[loc] ?? '';
}

class _Page extends StatelessWidget {
  const _Page({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
