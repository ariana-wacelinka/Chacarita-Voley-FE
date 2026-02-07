import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/io_client.dart';
import '../services/auth_service.dart';
import '../errors/backend_error_mapper.dart';
import '../services/snackbar_service.dart';

class GraphQLClientFactory {
  static late GraphQLClient client;
  static bool _initialized = false;
  static late String _baseUrl;
  static AuthService? _authService;

  static void init({required String baseUrl, String? token}) {
    if (_initialized) {
      // Si ya está inicializado, solo actualizar el cliente
      _updateClient();
      return;
    }

    _baseUrl = baseUrl;
    _authService = AuthService();
    _updateClient();
    _initialized = true;
  }

  static void _updateClient() {
    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 15);

    final ioClient = IOClient(httpClient);
    final httpLink = HttpLink(
      _baseUrl,
      httpClient: ioClient,
      defaultHeaders: {'Connection': 'close'},
    );

    // AuthLink con renovación proactiva de token
    final authLink = AuthLink(
      getToken: () async {
        if (_authService == null) return null;
        final token = await _authService!.getValidAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) {
        final errors = response?.errors ?? [];
        for (final error in errors) {
          final message = BackendErrorMapper.fromMessage(error.message);
          SnackbarService.showError(message);
        }
        return forward(request);
      },
      onException: (request, forward, exception) {
        final message = BackendErrorMapper.fromException(exception);
        SnackbarService.showError(message);
        return forward(request);
      },
    );

    final link = Link.from([errorLink, authLink, httpLink]);

    client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly),
        watchQuery: Policies(fetch: FetchPolicy.cacheAndNetwork),
      ),
    );
  }

  static String get baseUrl {
    if (!_initialized) {
      throw StateError('GraphQLClientFactory.init must be called first');
    }
    return _baseUrl;
  }

  /// Actualiza el cliente (útil después de login/logout)
  static void updateToken(String? newToken) {
    if (!_initialized) {
      throw StateError(
        'GraphQLClientFactory.init must be called first before updating token',
      );
    }
    // Ya no necesitamos guardar el token, AuthLink lo obtiene dinámicamente
    _updateClient();
  }

  /// Ejecuta una operación con un cliente HTTP "fresh" (IOClient nuevo)
  /// y lo cierra al finalizar. Útil para refetch inmediato post-mutation,
  /// evitando reutilizar sockets cerrados por el backend.
  static Future<T> withFreshClient<T>({
    required Future<T> Function(GraphQLClient client) run,
  }) async {
    if (!_initialized) {
      throw StateError('GraphQLClientFactory.init must be called first');
    }

    final httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 15);

    final ioClient = IOClient(httpClient);
    final httpLink = HttpLink(
      _baseUrl,
      httpClient: ioClient,
      defaultHeaders: {'Connection': 'keep-alive', 'Keep-Alive': 'timeout=30'},
    );

    // AuthLink con renovación proactiva (igual que el cliente principal)
    final authLink = AuthLink(
      getToken: () async {
        if (_authService == null) return null;
        final token = await _authService!.getValidAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) {
        final errors = response?.errors ?? [];
        for (final error in errors) {
          final message = BackendErrorMapper.fromMessage(error.message);
          SnackbarService.showError(message);
        }
        return forward(request);
      },
      onException: (request, forward, exception) {
        final message = BackendErrorMapper.fromException(exception);
        SnackbarService.showError(message);
        return forward(request);
      },
    );

    final link = Link.from([errorLink, authLink, httpLink]);

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
