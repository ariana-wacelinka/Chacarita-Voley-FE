import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/app.dart';
import 'app/theme/theme_provider.dart';
import 'core/environment.dart';
import 'core/network/graphql_client_factory.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/auth_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.notification?.title}');
}

void main() async {
  assert(
    Environment.baseUrl.isNotEmpty,
    'BACKEND_URL no definido. Ejecutar con --dart-define=BACKEND_URL=...',
  );
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Obtener token del AuthService si existe
  final authService = AuthService();
  final token = await authService.getToken();

  GraphQLClientFactory.init(baseUrl: Environment.graphqlBaseUrl, token: token);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessagingService().initialize();

  runApp(
    ProviderScope(
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}
