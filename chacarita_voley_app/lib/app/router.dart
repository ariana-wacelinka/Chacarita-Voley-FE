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
import '../features/teams/presentation/pages/edit_team_page.dart';
import '../features/teams/presentation/pages/view_team_page.dart';
import '../features/trainings/presentation/pages/trainings_page.dart';
import '../features/trainings/presentation/pages/attendance_training_page.dart';
import '../features/trainings/presentation/pages/new_training_page.dart';
import '../features/trainings/presentation/pages/view_training_page.dart';
import '../features/trainings/presentation/pages/edit_training_page.dart';
import '../features/trainings/presentation/pages/edit_session_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/notifications/presentation/pages/new_notification_page.dart';
import '../features/notifications/presentation/pages/new_notification_for_user_page.dart';
import '../features/notifications/presentation/pages/view_notification_page.dart';
import '../features/notifications/presentation/pages/edit_notification_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/change_password_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final title = _titleForLocation(state.uri.path);
        final subtitle = _subtitleForLocation(state);
        final isTeamTrainings =
            state.uri.path == '/trainings' &&
            state.uri.queryParameters['teamId'] != null;
        final teamId = state.uri.queryParameters['teamId'];

        return AppScaffold(
          title: title,
          subtitle: subtitle,
          child: child,
          showDrawer: !isTeamTrainings,
          onBack: isTeamTrainings && teamId != null
              ? () => context.go('/teams/view/$teamId')
              : null,
        );
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
          builder: (_, __) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/trainings',
          name: 'trainings',
          builder: (_, state) => TrainingsPage(
            teamId: state.uri.queryParameters['teamId'],
            teamName: state.uri.queryParameters['teamName'],
            refresh: state.uri.queryParameters['refresh'],
          ),
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
      path: '/users/:id/notification',
      name: 'users-notification',
      builder: (_, state) => NewNotificationForUserPage(
        userId: state.pathParameters['id']!,
        userName: state.uri.queryParameters['userName'] ?? 'Usuario',
      ),
    ),
    GoRoute(
      path: '/teams/register',
      name: 'teams-register',
      builder: (_, __) => const RegisterTeamPage(),
    ),
    GoRoute(
      path: '/teams/view/:id',
      name: 'teams-view',
      builder: (_, state) => ViewTeamPage(
        key: ValueKey('team-view-${state.pathParameters['id']}'),
        teamId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/teams/edit/:id',
      name: 'teams-edit',
      builder: (_, state) => EditTeamPage(
        key: ValueKey('team-edit-${state.pathParameters['id']}'),
        teamId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/trainings/create',
      name: 'trainings-create',
      builder: (_, state) => NewTrainingPage(
        teamId: state.uri.queryParameters['teamId'],
        teamName: state.uri.queryParameters['teamName'],
      ),
    ),
    GoRoute(
      path: '/trainings/:id',
      name: 'trainings-view',
      builder: (_, state) =>
          ViewTrainingPage(trainingId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trainings/:id/edit',
      name: 'trainings-edit',
      builder: (_, state) =>
          EditTrainingPage(trainingId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/sessions/:id/edit',
      name: 'sessions-edit',
      builder: (_, state) =>
          EditSessionPage(sessionId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/trainings/:id/attendance',
      name: 'trainings-attendance',
      builder: (_, state) =>
          AttendanceTrainingPage(trainingId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/notifications/new',
      name: 'new-notification',
      builder: (_, __) => const NewNotificationPage(),
    ),
    GoRoute(
      path: '/notifications/:id',
      name: 'notifications-view',
      builder: (_, state) =>
          ViewNotificationPage(notificationId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/notifications/:id/edit',
      name: 'notifications-edit',
      builder: (_, state) =>
          EditNotificationPage(notificationId: state.pathParameters['id']!),
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
    '/users': 'Gestión de Usuarios',
    '/payments': 'Gestión de Cuotas',
    '/teams': 'Gestión de Equipos',
    '/notifications': 'Gestión de Notificaciones',
    '/trainings': 'Gestión de Entrenamientos',
    '/settings': 'Configuraciones',
  };
  return map[loc] ?? '';
}

String? _subtitleForLocation(GoRouterState state) {
  if (state.uri.path == '/trainings') {
    return state.uri.queryParameters['teamName'];
  }
  return null;
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
