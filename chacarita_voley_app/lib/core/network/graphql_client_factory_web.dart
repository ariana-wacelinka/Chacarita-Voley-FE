import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/auth_service.dart';

class GraphQLClientFactory {
  static late GraphQLClient client;
  static bool _initialized = false;
  static late String _baseUrl;
  static AuthService? _authService;

  static void init({required String baseUrl, String? token}) {
    if (_initialized) {
      _updateClient();
      return;
    }

    _baseUrl = baseUrl;
    _authService = AuthService();
    _updateClient();
    _initialized = true;
  }

  static void _updateClient() {
    final httpLink = HttpLink(_baseUrl);

    final authLink = AuthLink(
      getToken: () async {
        if (_authService == null) return null;
        final token = await _authService!.getValidAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final link = authLink.concat(httpLink);

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

  static void updateToken(String? newToken) {
    if (!_initialized) {
      throw StateError(
        'GraphQLClientFactory.init must be called first before updating token',
      );
    }
    _updateClient();
  }

  static Future<T> withFreshClient<T>({
    required Future<T> Function(GraphQLClient client) run,
  }) async {
    if (!_initialized) {
      throw StateError('GraphQLClientFactory.init must be called first');
    }

    final httpLink = HttpLink(_baseUrl);
    final authLink = AuthLink(
      getToken: () async {
        if (_authService == null) return null;
        final token = await _authService!.getValidAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final link = authLink.concat(httpLink);
    final freshClient = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );

    return await run(freshClient);
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
