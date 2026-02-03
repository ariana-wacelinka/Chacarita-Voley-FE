import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'app_drawer.dart';
import '../theme/app_theme.dart';
import '../../features/home/presentation/widgets/notifications_panel.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/permissions_service.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.drawer,
    this.subtitle,
    this.showDrawer = true,
    this.onBack,
  });

  final String title;
  final Widget child;
  final Widget? drawer;
  final String? subtitle;
  final bool showDrawer;
  final VoidCallback? onBack;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  List<String> _userRoles = [];
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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

  void _showNotificationsPanel(BuildContext context) {
    if (_userId == null) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: position.top - 10,
            right: 8,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.35,
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 350,
                ),
                child: NotificationsPanel(personId: _userId.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayerRole = _userRoles.contains('PLAYER');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (widget.onBack != null) {
          widget.onBack!();
          return;
        }

        final currentRoute = GoRouterState.of(context).uri.path;
        if (currentRoute == '/home') {
          // Si estamos en home, permitir cerrar la app
          // No hacemos nada y Flutter cerrará la app
        } else {
          // Si no estamos en home, navegar a home
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: context.tokens.drawer,
        appBar: AppBar(
          leading: widget.onBack != null
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: context.tokens.text),
                  onPressed: widget.onBack,
                )
              : null,
          title: Center(
            child: Transform.translate(
              offset: Offset(hasPlayerRole ? 0 : -20, 0),
              child: widget.subtitle == null
                  ? Text(widget.title, textAlign: TextAlign.center)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.title, textAlign: TextAlign.center),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.tokens.placeholder,
                                fontSize: 12,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              // final currentPath = GoRouterState.of(context).uri.path;
              // return Scaffold(
              //   appBar: AppBar(title: Text(title)),
              //   drawer:
              //       drawer ??
              //       Drawer(
              //         child: SafeArea(
              //           child: Column(
              //             children: [
              //               const ListTile(
              //                 leading: Icon(Icons.home),
              //                 title: Text('Inicio'),
              //               ),
              //               ListTile(
              //                 leading: const Icon(Icons.payment),
              //                 title: const Text('Gestión de cuotas'),
              //                 selected: currentPath == '/payments',
              //                 onTap: () {
              //                   context.goNamed('payments');
              //                   Navigator.pop(context);
              //                 },
              //               ),
              //               //TODO pruebas para ver las pantallas
              //               ListTile(
              //                 leading: const Icon(Icons.payment),
              //                 title: const Text('history'),
              //                 selected: currentPath == '/payments_history',
              //                 onTap: () {
              //                   context.goNamed('history');
              //                   Navigator.pop(context);
              //                 },
              //               ),
              //               //Fin pruebas pantallas
              //             ],
              //           ),
            ),
          ),
          actions: hasPlayerRole
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Symbols.notifications,
                          color: context.tokens.text,
                        ),
                        onPressed: () => _showNotificationsPanel(context),
                      ),
                    ),
                  ),
                ]
              : null,
          backgroundColor: context.tokens.drawer,
          centerTitle: false,
          foregroundColor: context.tokens.text,
          elevation: 0,
        ),
        drawer: widget.showDrawer ? (widget.drawer ?? const AppDrawer()) : null,
        body: SafeArea(child: widget.child),
      ),
    );
  }
}
