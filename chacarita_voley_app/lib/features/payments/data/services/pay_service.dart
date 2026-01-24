import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import 'pay_service_interface.dart';
import '../models/pay_response_model.dart';

class PayService implements PayServiceInterface {
  final GraphQLClient _graphQLClient;

  PayService({required GraphQLClient graphQLClient})
    : _graphQLClient = graphQLClient;

  @override
  Future<PaginatedPayResponse> getAllPays({
    int page = 0,
    int size = 10,
    Map<String, dynamic>? filters,
  }) async {
    final result = await _graphQLClient.query(
      QueryOptions(
        document: gql('''
          query GetAllPays(\$page: Int!, \$size: Int!, \$filters: PayFilterInput) {
            getAllPays(page: \$page, size: \$size, filters: \$filters) {
              content {
                # fields
              }
              # pagination fields
            }
          }
        '''),
        variables: {'page': page, 'size': size, 'filters': filters},
      ),
    );

    if (result.hasException) throw result.exception!;

    return PaginatedPayResponse.fromJson(
      result.data!['getAllPays'] as Map<String, dynamic>,
    );
  }

  @override
  Future<PayResponseModel> createPay(Map<String, dynamic> input) {
    // TODO: implement createPay
    throw UnimplementedError();
  }

  @override
  Future<void> deletePay(String id) {
    // TODO: implement deletePay
    throw UnimplementedError();
  }

  @override
  Future<PayResponseModel?> getPayById(String id) {
    // TODO: implement getPayById
    throw UnimplementedError();
  }

  @override
  Future<PaginatedPayResponse> getPayPage({
    Map<String, dynamic>? filter,
    int? page,
    int? size,
  }) {
    // TODO: implement getPayPage
    throw UnimplementedError();
  }

  @override
  Future<List<PayResponseModel>> getPays({
    Map<String, dynamic>? filter,
    int? page,
    int? size,
  }) {
    // TODO: implement getPays
    throw UnimplementedError();
  }

  @override
  Future<PayResponseModel> updatePay(Map<String, dynamic> input) {
    // TODO: implement updatePay
    throw UnimplementedError();
  }

  // Similar para create, update, etc.
}
