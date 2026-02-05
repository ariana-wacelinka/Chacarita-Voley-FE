import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import './router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Chacarita Voley',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          routerConfig: appRouter,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', ''), Locale('en', '')],
          builder: (context, child) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;

                final currentLocation =
                    appRouter.routerDelegate.currentConfiguration.uri.path;
                print(
                  '🔙 Back button pressed. Current location: $currentLocation',
                );

                if (currentLocation == '/home') {
                  print('📱 En home, saliendo de la app');
                  SystemNavigator.pop();
                } else {
                  print('↩️ Navegando hacia atrás');
                  if (appRouter.canPop()) {
                    appRouter.pop();
                  } else {
                    appRouter.go('/home');
                  }
                }
              },
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
