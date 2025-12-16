import 'package:go_router/go_router.dart';
import 'layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/users/presentation/pages/register_user_page.dart';
import '../features/users/presentation/pages/edit_user_page.dart';
import '../features/users/presentation/pages/view_user_page.dart';
import '../features/users/presentation/pages/attendance_history_page.dart';
import '../features/teams/presentation/pages/teams_page.dart';
import '../features/teams/presentation/pages/register_team_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/change_password_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final title = _titleForLocation(state.uri.path);
        return AppScaffold(title: title, child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, __) => const HomePage(),
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          builder: (_, __) => const UsersPage(),
        ),
        GoRoute(
          path: '/payments',
          name: 'payments',
          builder: (_, __) => const _Page(text: 'Gestión de Cuotas'),
        ),
        GoRoute(
          path: '/teams',
          name: 'teams',
          builder: (_, __) => const TeamsPage(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (_, __) => const _Page(text: 'Gestión de Notificaciones'),
        ),
        GoRoute(
          path: '/trainings',
          name: 'trainings',
          builder: (_, __) => const _Page(text: 'Gestión de Entrenamientos'),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (_, __) => const SettingsPage(),
        ),
      ],
    ),

    GoRoute(
      path: '/users/register',
      name: 'users-register',
      builder: (_, __) => const RegisterUserPage(),
    ),
    GoRoute(
      path: '/users/:id/edit',
      name: 'users-edit',
      builder: (_, state) => EditUserPage(userId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/users/:id/view',
      name: 'users-view',
      builder: (_, state) => ViewUserPage(userId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/users/:id/attendance',
      name: 'users-attendance',
      builder: (_, state) =>
          AttendanceHistoryPage(userId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/teams/register',
      name: 'teams-register',
      builder: (_, __) => const RegisterTeamPage(),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (_, __) => const ChangePasswordPage(),
    ),
  ],
);

String _titleForLocation(String loc) {
  const map = {
    '/home': '',
    '/users': 'Gestión de Jugadores',
    '/payments': 'Gestión de Cuotas',
    '/teams': 'Gestión de Equipos',
    '/notifications': 'Gestión de Notificaciones',
    '/trainings': 'Gestión de Entrenamientos',
    '/settings': 'Configuraciones',
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
