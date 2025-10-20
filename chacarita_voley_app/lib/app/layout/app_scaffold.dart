import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: context.tokens.drawer,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: context.tokens.drawer,
        centerTitle: true,
        foregroundColor: context.tokens.text,
        elevation: 0,
      ),
      drawer: drawer ?? const AppDrawer(),
      body: SafeArea(
        child: child,
      ),
    );
  }
}
