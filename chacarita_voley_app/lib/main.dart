import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'app/theme/theme_provider.dart';
import 'core/environment.dart';
import 'core/network/graphql_client_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GraphQLClientFactory.init(
    baseUrl: Environment.baseUrl,
    token: 'mock-token',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}
