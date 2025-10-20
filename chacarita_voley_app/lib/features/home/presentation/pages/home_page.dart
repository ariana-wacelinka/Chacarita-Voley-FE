import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/notification_item.dart';
import '../widgets/training_item.dart';
import '../../../../app/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tokens.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Socios totales',
                    value: '999',
                    icon: Symbols.group,
                    color: context.tokens.text,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Pagos vencidos',
                    value: '999',
                    icon: Symbols.warning,
                    color: context.tokens.redToRosita,
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
                    value: '999',
                    icon: Symbols.calendar_today,
                    color: context.tokens.text,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Notificaciones',
                    value: '999',
                    icon: Symbols.notifications,
                    color: context.tokens.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(
              'Acciones rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.tokens.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            QuickActionCard(
              title: 'Gestionar cuotas',
              icon: Symbols.credit_card,
              onTap: () => context.go('/payments'),
            ),
            const SizedBox(height: 12),
            QuickActionCard(
              title: 'Gestionar jugadores',
              icon: Symbols.group,
              onTap: () => context.go('/users'),
            ),
            const SizedBox(height: 12),
            QuickActionCard(
              title: 'Gestionar notificaciones',
              icon: Symbols.notifications,
              onTap: () => context.go('/notifications'),
            ),
            const SizedBox(height: 12),
            QuickActionCard(
              title: 'Gestionar equipos',
              icon: Symbols.sports_volleyball,
              onTap: () => context.go('/teams'),
            ),
            const SizedBox(height: 32),

            Text(
              'Recordatorios y notificaciones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.tokens.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            NotificationItem(
              title: '999 socios con pagos vencidos',
              isImportant: true,
              onTap: () => context.go('/notifications'),
            ),
            const SizedBox(height: 12),
            NotificationItem(
              title: 'Notificación genérica: Ejemplo de notif...',
              isImportant: false,
              onTap: () => context.go('/notifications'),
            ),
            const SizedBox(height: 12),
            NotificationItem(
              title: 'Notificación genérica: Ejemplo de notif...',
              isImportant: false,
              onTap: () => context.go('/notifications'),
            ),
            const SizedBox(height: 32),

            Text(
              'Entrenamientos hoy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.tokens.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TrainingItem(
              category: 'Recreativo 1',
              subtitle: 'Prof. Ayala, Pavel - 13 jugadores',
              time: '18:00',
              attendance: '10/13',
              onTap: () => context.go('/trainings'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
