import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/notification_item.dart';
import '../widgets/training_item.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/di.dart';
import '../../domain/models/home_stats.dart';
import '../../domain/models/notification_preview.dart';
import '../../domain/models/training_preview.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  HomeStats? _stats;
  List<NotificationPreview> _notifications = [];
  List<TrainingPreview> _trainings = [];
  bool _isLoading = true;
  List<String> _userRoles = [];
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
    _loadData();
  }

  Future<void> _loadUserRoles() async {
    final authService = AuthService();
    final roles = await authService.getUserRoles();
    final userId = await authService.getUserId();
    if (mounted) {
      setState(() {
        _userRoles = roles ?? [];
        _userId = userId;
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final repository = ref.read(homeRepositoryProvider);
      final stats = await repository.getStats();
      final notifications = await repository.getScheduledNotifications();
      final trainings = await repository.getTodayTrainings();
      if (mounted) {
        setState(() {
          _stats = stats;
          _notifications = notifications;
          _trainings = trainings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = HomeStats.empty();
          _notifications = [];
          _trainings = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats ?? HomeStats.empty();
    final isPlayer = PermissionsService.isPlayer(_userRoles);

    return Scaffold(
      backgroundColor: context.tokens.background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards solo para ADMIN y PROFESSOR
                  if (!isPlayer) ...[
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Socios totales',
                            value: stats.totalMembers.toString(),
                            icon: Symbols.group,
                            color: context.tokens.text,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Pagos vencidos',
                            value: stats.totalOverdueDues.toString(),
                            icon: Symbols.warning,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Entrenamientos hoy',
                            value: stats.totalTrainingToday.toString(),
                            icon: Symbols.calendar_today,
                            color: context.tokens.text,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Notificaciones',
                            value: stats.totalScheduledNotifications.toString(),
                            icon: Symbols.notifications,
                            color: context.tokens.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  Text(
                    'Acciones rápidas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.tokens.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Acciones para JUGADORES
                  if (isPlayer && _userId != null) ...[
                    QuickActionCard(
                      title: 'Gestionar pagos',
                      icon: Symbols.credit_card,
                      onTap: () => context.go('/users/$_userId/payments'),
                    ),
                    const SizedBox(height: 12),
                    QuickActionCard(
                      title: 'Visualizar asistencias',
                      icon: Symbols.check_circle,
                      onTap: () => context.go('/users/$_userId/attendance'),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Acciones para ADMIN y PROFESSOR
                  if (!isPlayer) ...[
                    if (PermissionsService.canAccessPayments(_userRoles))
                      QuickActionCard(
                        title: 'Gestionar cuotas',
                        icon: Symbols.credit_card,
                        onTap: () => context.go('/payments'),
                      ),
                    if (PermissionsService.canAccessPayments(_userRoles))
                      const SizedBox(height: 12),
                    if (PermissionsService.canAccessUsers(_userRoles))
                      QuickActionCard(
                        title: 'Gestionar usuarios',
                        icon: Symbols.group,
                        onTap: () => context.go('/users'),
                      ),
                    if (PermissionsService.canAccessUsers(_userRoles))
                      const SizedBox(height: 12),
                    if (PermissionsService.canAccessNotifications(_userRoles))
                      QuickActionCard(
                        title: 'Gestionar notificaciones',
                        icon: Symbols.notifications,
                        onTap: () => context.go('/notifications'),
                      ),
                    if (PermissionsService.canAccessNotifications(_userRoles))
                      const SizedBox(height: 12),
                    if (PermissionsService.canAccessTeams(_userRoles))
                      QuickActionCard(
                        title: 'Gestionar equipos',
                        icon: Symbols.sports_volleyball,
                        onTap: () => context.go('/teams'),
                      ),
                    if (PermissionsService.canAccessTeams(_userRoles))
                      const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 32),

                  Text(
                    'Recordatorios y notificaciones',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.tokens.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_notifications.isEmpty)
                    NotificationItem(
                      title: isPlayer
                          ? 'No tienes notificaciones pendientes'
                          : 'No hay notificaciones programadas',
                      isImportant: false,
                      onTap: isPlayer
                          ? null
                          : () => context.go('/notifications'),
                    )
                  else
                    ..._notifications.asMap().entries.map((entry) {
                      final notification = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.key < _notifications.length - 1
                              ? 12
                              : 0,
                        ),
                        child: NotificationItem(
                          title: notification.title,
                          isImportant: false,
                          onTap: isPlayer
                              ? null
                              : () => context.go('/notifications'),
                        ),
                      );
                    }),
                  const SizedBox(height: 32),

                  Text(
                    isPlayer
                        ? 'Entrenamientos los próximos 7 días'
                        : 'Entrenamientos hoy',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.tokens.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_trainings.isEmpty)
                    TrainingItem(
                      category: 'Sin entrenamientos',
                      subtitle: isPlayer
                          ? 'No tienes entrenamientos programados esta semana'
                          : 'No hay entrenamientos programados para hoy',
                      time: '--:--',
                      attendance: '-/-',
                      onTap: isPlayer ? null : () => context.go('/trainings'),
                    )
                  else
                    ..._trainings.asMap().entries.map((entry) {
                      final training = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.key < _trainings.length - 1 ? 16 : 0,
                        ),
                        child: TrainingItem(
                          category: training.teamName,
                          subtitle:
                              'Prof. ${training.professorName} - ${training.totalPlayers} jugadores',
                          time: training.formattedTime,
                          attendance:
                              '${training.attendance}/${training.totalPlayers}',
                          onTap: isPlayer
                              ? null
                              : () => context.go('/trainings/${training.id}'),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
