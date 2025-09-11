import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLClientFactory {
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
