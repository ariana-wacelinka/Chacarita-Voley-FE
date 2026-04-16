import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wrapper para páginas fuera del ShellRoute que maneja el botón back correctamente
class PageWrapper extends StatelessWidget {
  final Widget child;
  final String fallbackRoute;

  const PageWrapper({
    super.key,
    required this.child,
    this.fallbackRoute = '/home',
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(fallbackRoute);
        }
      },
      child: child,
    );
  }
}
