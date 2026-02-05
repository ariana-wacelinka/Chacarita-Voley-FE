import 'package:chacarita_voley_app/features/payments/presentation/pages/edit_payments_page.dart';
import 'package:chacarita_voley_app/features/payments/presentation/pages/create_payment_page.dart';
import 'package:chacarita_voley_app/features/payments/presentation/pages/payment_detail_page.dart';
import 'package:go_router/go_router.dart';
import '../features/payments/presentation/pages/payments_validation_page.dart';
import '../features/payments/presentation/pages/payment_history_page.dart';
import 'layout/app_scaffold.dart';
import 'layout/page_wrapper.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
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
import '../features/notifications/presentation/pages/new_notification_for_team_page.dart';
import '../features/notifications/presentation/pages/view_notification_page.dart';
import '../features/notifications/presentation/pages/edit_notification_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/change_password_page.dart';
import '../core/services/auth_service.dart';
import '../core/services/permissions_service.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final isLoginPage = state.matchedLocation == '/login';
    final isForgotPasswordPage = state.matchedLocation == '/forgot-password';
    final authService = AuthService();

    // Si estamos en login o forgot password, permitir acceso
    if (isLoginPage) {
      final shouldRemember = await authService.shouldRememberSession();
      final token = await authService.getToken();

      print(
        '🔐 En login page - shouldRemember: $shouldRemember, hasToken: ${token != null}',
      );

      // Si tiene "recordarme" activo y tiene token, redirigir a home
      if (shouldRemember && token != null) {
        print('✅ Sesión recordada, redirigiendo a /home');
        return '/home';
      }
      return null;
    }

    // Permitir acceso a forgot password sin autenticación
    if (isForgotPasswordPage) {
      return null;
    }

    final token = await authService.getToken();

    if (token == null) {
      return '/login';
    }

    final roles = await authService.getUserRoles() ?? [];
    final userId = await authService.getUserId();
    final path = state.matchedLocation;

    print('🔀 Router redirect - Path: $path');
    print('👤 User roles: $roles');
    print('🆔 User ID: $userId');

    // Extraer el ID de la URL si existe
    final userIdInPath = RegExp(r'/users/(\d+)').firstMatch(path)?.group(1);
    print('🔢 User ID en path: $userIdInPath');

    // Permitir a los jugadores acceder a su propio historial
    final isOwnPaymentHistory =
        path.contains('/payments') &&
        path.startsWith('/users/') &&
        userIdInPath == userId.toString();
    final isOwnAttendanceHistory =
        path.contains('/attendance') &&
        path.startsWith('/users/') &&
        userIdInPath == userId.toString();
    final isOwnProfile =
        RegExp(r'^/users/\d+/view$').hasMatch(path) &&
        userIdInPath == userId.toString();
    final isOwnEdit =
        RegExp(r'^/users/\d+/edit$').hasMatch(path) &&
        userIdInPath == userId.toString();

    print('💳 isOwnPaymentHistory: $isOwnPaymentHistory');
    print('✅ isOwnAttendanceHistory: $isOwnAttendanceHistory');
    print('👨 isOwnProfile: $isOwnProfile');
    print('✏️ isOwnEdit: $isOwnEdit');

    // Usuarios - excluir historial propio de pagos y asistencias
    if (path.startsWith('/users') &&
        !isOwnPaymentHistory &&
        !isOwnAttendanceHistory &&
        !isOwnProfile &&
        !isOwnEdit &&
        !PermissionsService.canAccessUsers(roles)) {
      print('❌ Bloqueando acceso a /users - Redirigiendo a /home');
      return '/home';
    }
    if (path == '/users/register' && !PermissionsService.canCreateUser(roles)) {
      return '/home';
    }
    if (path.contains('/edit') &&
        path.startsWith('/users') &&
        !isOwnEdit &&
        !PermissionsService.canEditUser(roles)) {
      return '/home';
    }

    // Pagos - validación principal y edición
    if (path == '/payments' && !PermissionsService.canAccessPayments(roles)) {
      return '/home';
    }
    if (path.startsWith('/payments/create') &&
        !PermissionsService.canCreatePayment(roles)) {
      return '/home';
    }
    if (path.startsWith('/payments/edit') &&
        !PermissionsService.canEditPayment(roles)) {
      return '/home';
    }
    if (path.startsWith('/payments/detail') &&
        !PermissionsService.canValidatePayments(roles)) {
      return '/home';
    }

    // Notificaciones
    if (path.startsWith('/notifications') &&
        !PermissionsService.canAccessNotifications(roles)) {
      return '/home';
    }

    // Equipos
    if (path.startsWith('/teams') &&
        !PermissionsService.canAccessTeams(roles)) {
      return '/home';
    }

    // Entrenamientos
    if (path.startsWith('/trainings') &&
        !PermissionsService.canAccessTrainings(roles)) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (_, __) => const ForgotPasswordPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final title = _titleForLocation(state.uri.path);
        final subtitle = _subtitleForLocation(state);
        final isTeamTrainings =
            state.uri.path == '/trainings' &&
            state.uri.queryParameters['teamId'] != null;
        final teamId = state.uri.queryParameters['teamId'];
        final isHomePage = state.uri.path == '/home';

        return AppScaffold(
          title: title,
          subtitle: subtitle,
          child: child,
          showDrawer: !isTeamTrainings,
          isHomePage: isHomePage,
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
          builder: (_, state) => PaymentsValidationPage(
            refresh: state.uri.queryParameters['refresh'],
          ),
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

    //Ruta persnalizada de Payments
    GoRoute(
      path: '/payments/create',
      name: 'payments-create',
      builder: (_, state) => PageWrapper(
        child: CreatePaymentPage(
          userId: state.uri.queryParameters['userId'],
          userName: state.uri.queryParameters['userName'],
        ),
      ),
    ),
    GoRoute(
      path: '/payments/detail/:id',
      name: 'payments-detail',
      builder: (_, state) => PageWrapper(
        child: PaymentDetailPage(
          paymentId: state.pathParameters['id']!,
          userName: state.uri.queryParameters['userName'],
        ),
      ),
    ),
    GoRoute(
      path: '/payments/edit/:id',
      name: 'payments-edit',
      builder: (_, state) => PageWrapper(
        child: EditPaymentsPage(paymentId: state.pathParameters['id']!),
      ),
    ),

    GoRoute(
      path: '/users/register',
      name: 'users-register',
      builder: (_, __) => const PageWrapper(child: RegisterUserPage()),
    ),
    GoRoute(
      path: '/users/:id/edit',
      name: 'users-edit',
      builder: (_, state) => PageWrapper(
        child: EditUserPage(
          userId: state.pathParameters['id']!,
          from: state.uri.queryParameters['from'],
        ),
      ),
    ),
    GoRoute(
      path: '/users/:id/view',
      name: 'users-view',
      builder: (_, state) => PageWrapper(
        child: ViewUserPage(
          userId: state.pathParameters['id']!,
          from: state.uri.queryParameters['from'],
          refresh: state.uri.queryParameters['refresh'],
        ),
      ),
    ),
    GoRoute(
      path: '/users/:id/attendance',
      name: 'users-attendance',
      builder: (_, state) => PageWrapper(
        child: AttendanceHistoryPage(userId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/users/:id/payments',
      name: 'users-payments',
      builder: (_, state) => PageWrapper(
        child: PaymentHistoryPage(
          userId: state.pathParameters['id']!,
          userName: state.uri.queryParameters['userName'] ?? 'Usuario',
        ),
      ),
    ),
    GoRoute(
      path: '/users/:id/notification',
      name: 'users-notification',
      builder: (_, state) => PageWrapper(
        child: NewNotificationForUserPage(
          userId: state.pathParameters['id']!,
          userName: state.uri.queryParameters['userName'] ?? 'Usuario',
        ),
      ),
    ),
    GoRoute(
      path: '/teams/register',
      name: 'teams-register',
      builder: (_, __) => const PageWrapper(child: RegisterTeamPage()),
    ),
    GoRoute(
      path: '/teams/view/:id',
      name: 'teams-view',
      builder: (_, state) => PageWrapper(
        child: ViewTeamPage(
          key: ValueKey('team-view-${state.pathParameters['id']}'),
          teamId: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      path: '/teams/:id/notification',
      name: 'teams-notification',
      builder: (_, state) => PageWrapper(
        child: NewNotificationForTeamPage(
          teamId: state.pathParameters['id']!,
          teamName: state.uri.queryParameters['teamName'] ?? 'Equipo',
        ),
      ),
    ),
    GoRoute(
      path: '/teams/edit/:id',
      name: 'teams-edit',
      builder: (_, state) => PageWrapper(
        child: EditTeamPage(
          key: ValueKey('team-edit-${state.pathParameters['id']}'),
          teamId: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      path: '/trainings/create',
      name: 'trainings-create',
      builder: (_, state) => PageWrapper(
        child: NewTrainingPage(
          teamId: state.uri.queryParameters['teamId'],
          teamName: state.uri.queryParameters['teamName'],
        ),
      ),
    ),
    GoRoute(
      path: '/trainings/:id',
      name: 'trainings-view',
      builder: (_, state) => PageWrapper(
        child: ViewTrainingPage(trainingId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/trainings/:id/edit',
      name: 'trainings-edit',
      builder: (_, state) => PageWrapper(
        child: EditTrainingPage(trainingId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/sessions/:id/edit',
      name: 'sessions-edit',
      builder: (_, state) => PageWrapper(
        child: EditSessionPage(sessionId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/trainings/:id/attendance',
      name: 'trainings-attendance',
      builder: (_, state) => PageWrapper(
        child: AttendanceTrainingPage(trainingId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/notifications/new',
      name: 'new-notification',
      builder: (_, __) => const PageWrapper(child: NewNotificationPage()),
    ),
    GoRoute(
      path: '/notifications/:id',
      name: 'notifications-view',
      builder: (_, state) => PageWrapper(
        child: ViewNotificationPage(notificationId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/notifications/:id/edit',
      name: 'notifications-edit',
      builder: (_, state) => PageWrapper(
        child: EditNotificationPage(notificationId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (_, __) => const PageWrapper(child: ChangePasswordPage()),
    ),
  ],
);

String _titleForLocation(String loc) {
  const map = {
    '/home': '',
    '/users': 'Gestión de Usuarios',
    '/payments': 'Validación de Pagos',
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
