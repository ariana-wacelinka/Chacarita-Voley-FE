import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../core/network/graphql_client_factory.dart';
import '../features/home/data/repositories/home_repository.dart';

final tokenProvider = StateProvider<String?>((ref) => null);

final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final token = ref.watch(tokenProvider);
  return GraphQLClientFactory.create(
    baseUrl: '',
    //Cuando Lu tenga el back arriba agregar la variable de entorno y reemplazar.
    token: token,
  );
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});
