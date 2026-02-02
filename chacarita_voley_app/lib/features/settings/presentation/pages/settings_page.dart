import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permissions_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authService = AuthService();
  List<String> _userRoles = [];
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final roles = await _authService.getUserRoles();
    final userId = await _authService.getUserId();
    if (mounted) {
      setState(() {
        _userRoles = roles ?? [];
        _userId = userId;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _logout();
            },
            child: Text(
              'Cerrar sesión',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al cerrar sesión: $e',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            elevation: 6,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode =
        themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            systemBrightness == Brightness.dark);
    final isPlayer = PermissionsService.isPlayer(_userRoles);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de perfil para jugadores
            if (isPlayer && _userId != null) ...[
              _buildSectionCard(
                context,
                icon: Icons.person,
                title: 'Mi Perfil',
                items: [
                  _SettingItem(
                    icon: Icons.account_circle,
                    title: 'Ver mi perfil',
                    showArrow: true,
                    onTap: () => context.go('/users/$_userId'),
                  ),
                  _SettingItem(
                    icon: Icons.credit_card,
                    title: 'Mis pagos',
                    showArrow: true,
                    onTap: () => context.go('/users/$_userId/payments'),
                  ),
                  _SettingItem(
                    icon: Icons.check_circle,
                    title: 'Mis asistencias',
                    showArrow: true,
                    onTap: () => context.go('/users/$_userId/attendance'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _buildSectionCard(
              context,
              icon: Icons.settings,
              title: 'Configuraciones',
              items: [
                _SettingItem(
                  icon: Icons.lock,
                  title: 'Cambiar contraseña',
                  showArrow: true,
                  onTap: () => context.go('/change-password'),
                ),
                _SettingItem(
                  icon: Icons.brightness_6,
                  title: 'Tema',
                  subtitle: isDarkMode ? 'Modo oscuro' : 'Modo claro',
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            GestureDetector(
              onTap: _showLogoutDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.tokens.card1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.tokens.stroke, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Cerrar Sesión',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<_SettingItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.tokens.text, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.tokens.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ...items.map((item) => _buildSettingItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, _SettingItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: item.onTap,
        child: Row(
          children: [
            Icon(item.icon, color: context.tokens.gray, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: context.tokens.text),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.tokens.gray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null)
              item.trailing!
            else if (item.showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: context.tokens.gray,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showArrow = false,
    this.onTap,
  });
}
