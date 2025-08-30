import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app/theme/app_theme.dart';
import 'app/layout/app_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Club Chacarita',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final title = _titleForLocation(state.uri.toString());
        return AppScaffold(title: title, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (_, __) => const _Page(text: ''),
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
  const map = {'/': ''};
  final base = Uri.parse(loc).path;
  return map[base] ?? '';
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
