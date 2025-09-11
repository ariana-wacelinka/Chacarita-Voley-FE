import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer:
          drawer ??
          const Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  ListTile(leading: Icon(Icons.home), title: Text('Inicio')),
                ],
              ),
            ),
          ),
      body: child,
    );
  }
}
