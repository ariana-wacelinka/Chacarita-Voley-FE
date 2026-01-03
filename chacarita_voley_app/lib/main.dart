import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/environment.dart';
import 'core/network/graphql_client_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GraphQLClientFactory.init(baseUrl: Environment.baseUrl);

  runApp(const MyApp());
}
