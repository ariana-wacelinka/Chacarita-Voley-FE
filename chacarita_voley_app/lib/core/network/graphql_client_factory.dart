import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/io_client.dart';

class GraphQLClientFactory {
  static late final GraphQLClient client;
  static bool _initialized = false;
  static late final String _baseUrl;
  static String? _token;

  static void init({required String baseUrl, String? token}) {
    if (_initialized) return;

    _baseUrl = baseUrl;
    _token = token;

    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 15);

    final httpLink = HttpLink(baseUrl, httpClient: IOClient(httpClient));

    Link link = httpLink;

    if (token != null) {
      final authLink = AuthLink(getToken: () async => 'Bearer $token');
      link = authLink.concat(httpLink);
    }

    client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );

    _initialized = true;
  }

  static String get baseUrl {
    if (!_initialized) {
      throw StateError('GraphQLClientFactory.init must be called first');
    }
    return _baseUrl;
  }

  static String? get token => _token;

  /// Ejecuta una operación con un cliente HTTP "fresh" (IOClient nuevo)
  /// y lo cierra al finalizar. Útil para refetch inmediato post-mutation,
  /// evitando reutilizar sockets cerrados por el backend.
  static Future<T> withFreshClient<T>({
    required Future<T> Function(GraphQLClient client) run,
  }) async {
    if (!_initialized) {
      throw StateError('GraphQLClientFactory.init must be called first');
    }

    final ioClient = IOClient(HttpClient());
    final httpLink = HttpLink(_baseUrl, httpClient: ioClient);

    Link link = httpLink;
    final token = _token;
    if (token != null) {
      final authLink = AuthLink(getToken: () async => 'Bearer $token');
      link = authLink.concat(httpLink);
    }

    final freshClient = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );

    try {
      return await run(freshClient);
    } finally {
      ioClient.close();
    }
  }

  @Deprecated('Use GraphQLClientFactory.client instead')
  static GraphQLClient create({required String baseUrl, String? token}) {
    final httpLink = HttpLink(baseUrl);

    Link link = httpLink;

    if (token != null) {
      final authLink = AuthLink(getToken: () async => 'Bearer $token');
      link = authLink.concat(httpLink);
    }

    return GraphQLClient(cache: GraphQLCache(), link: link);
  }
}
