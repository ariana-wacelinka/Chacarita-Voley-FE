import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final currentPath = GoRouterState.of(context).uri.path;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer:
          drawer ??
          Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Inicio'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Gestión de cuotas'),
                    selected: currentPath == '/payments',
                    onTap: () {
                      context.goNamed('payments');
                      Navigator.pop(context);
                    },
                  ),
                  //TODO pruebas para ver las pantallas
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('history'),
                    selected: currentPath == '/payments_history',
                    onTap: () {
                      context.goNamed('history');
                      Navigator.pop(context);
                    },
                  ),
                  //Fin pruebas pantallas
                ],
              ),
            ),
          ),
      body: child,
    );
  }
}
