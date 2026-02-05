import 'package:flutter/material.dart';

/// Wrapper para páginas fuera del ShellRoute que maneja el botón back correctamente
class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
