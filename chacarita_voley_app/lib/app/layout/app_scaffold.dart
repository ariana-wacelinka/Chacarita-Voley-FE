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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (onBack != null) {
          onBack!();
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
          leading: onBack != null
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: context.tokens.text),
                  onPressed: onBack,
                )
              : null,
          title: subtitle == null
              ? Text(title)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.tokens.placeholder,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
          backgroundColor: context.tokens.drawer,
          centerTitle: true,
          foregroundColor: context.tokens.text,
          elevation: 0,
        ),
        drawer: showDrawer ? (drawer ?? const AppDrawer()) : null,
        body: SafeArea(child: child),
      ),
    );
  }
}
