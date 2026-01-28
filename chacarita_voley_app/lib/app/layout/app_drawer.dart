import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: context.tokens.drawer,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/chacarita_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.sports_volleyball,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chacarita Voley',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.tokens.permanentWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Club de Vóley',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.tokens.permanentWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home,
                    title: 'Inicio',
                    isSelected: currentLocation == '/home',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people,
                    title: 'Gestión de Usuarios',
                    isSelected: currentLocation == '/users',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/users');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.payment,
                    title: 'Gestión de Cuotas',
                    isSelected: currentLocation == '/payments',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/payments');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.notifications,
                    title: 'Gestión de Notificaciones',
                    isSelected: currentLocation == '/notifications',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/notifications');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.sports_volleyball,
                    title: 'Gestión de Equipos',
                    isSelected: currentLocation == '/teams',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/teams');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_today,
                    title: 'Gestión de Entrenamientos',
                    isSelected: currentLocation == '/trainings',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/trainings');
                    },
                  ),
                ],
              ),
            ),

            const Divider(),
            _DrawerItem(
              icon: Icons.settings,
              title: 'Configuraciones',
              isSelected: currentLocation == '/settings',
              onTap: () {
                Navigator.pop(context);
                context.go('/settings');
              },
            ),
            _DrawerItem(
              icon: Icons.logout,
              title: 'Cerrar Sesión',
              isSelected: false,
              isLogout: true,
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que querés cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                context.go('/');
              },
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLogout;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? tokens.redToRosita.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout
              ? Theme.of(context).colorScheme.error
              : isSelected
              ? tokens.redToRosita
              : tokens.placeholder,
          size: 22,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isLogout
                ? Theme.of(context).colorScheme.error
                : isSelected
                ? tokens.redToRosita
                : tokens.text,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
