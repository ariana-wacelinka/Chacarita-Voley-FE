import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.drawer,
  });

  final String title;
  final Widget child;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

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
          title: Text(title),
          backgroundColor: context.tokens.drawer,
          centerTitle: true,
          foregroundColor: context.tokens.text,
          elevation: 0,
        ),
        drawer: drawer ?? const AppDrawer(),
        body: SafeArea(child: child),
      ),
    );
  }
}
