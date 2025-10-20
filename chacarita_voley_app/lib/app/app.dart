import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import './router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chacarita Voley',
      debugShowCheckedModeBanner: false, // Quitar banner de debug
      theme: AppTheme.light, // Tema claro como principal
      darkTheme: AppTheme.dark, // Tema oscuro disponible
      themeMode: ThemeMode.light, // Forzar tema claro por defecto
      routerConfig: appRouter,
    );
  }
}
