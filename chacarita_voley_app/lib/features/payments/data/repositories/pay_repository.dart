import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/payment_stats.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/update_pay_input.dart';
import 'package:chacarita_voley_app/features/payments/domain/repositories/pay_repository_interface.dart';
import '../../domain/entities/create_pay_input.dart';
import '../../domain/entities/pay_page.dart';
import '../../domain/entities/pay_filter_input.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../models/pay_response_model.dart';

class PayRepository implements PayRepositoryInterface {
  // Datos dummy eliminados - ahora usa GraphQL real

  //TODO de aca hasta el otro ToDo de abajo
  @override
  Future<PayPage> getAllPays({
    int page = 0,
    int size = 10,
    PayFilterInput? filters,
  }) async {
    // Construir filtros dinámicamente (sin state si es null)
    final Map<String, dynamic> filtersMap = {};

    if (filters?.state != null) {
      filtersMap['state'] = filters!.state!.name.toUpperCase();
    }
    if (filters?.dateFrom != null && filters!.dateFrom!.isNotEmpty) {
      filtersMap['dateFrom'] = filters.dateFrom;
    }
    if (filters?.dateTo != null && filters!.dateTo!.isNotEmpty) {
      filtersMap['dateTo'] = filters.dateTo;
    }
    if (filters?.timeFrom != null && filters!.timeFrom!.isNotEmpty) {
      filtersMap['timeFrom'] = filters.timeFrom;
    }
    if (filters?.timeTo != null && filters!.timeTo!.isNotEmpty) {
      filtersMap['timeTo'] = filters.timeTo;
    }

    final result = await _query(
      QueryOptions(
        document: gql('''
          query GetAllPays(\$page: Int!, \$size: Int!, \$filters: PayFilterInput!) {
            getAllPays(page: \$page, size: \$size, filters: \$filters) {
              totalPages
              totalElements
              pageSize
              pageNumber
              hasPrevious
              hasNext
              content {
                state
                amount
                date
                fileName
                fileUrl
                id
                time
                player {
                  id
                  person {
                    id
                    name
                    surname
                    dni
                  }
                }
              }
            }
          }
        '''),
        variables: {'page': page, 'size': size, 'filters': filtersMap},
      ),
    );

    if (result.hasException) throw result.exception!;

    final data = result.data!['getAllPays'] as Map<String, dynamic>;

    return PayPage(
      content: (data['content'] as List)
          .map((json) => Pay.fromJson(json as Map<String, dynamic>))
          .toList(),
      totalElements: data['totalElements'] as int,
      totalPages: data['totalPages'] as int,
      pageNumber: data['pageNumber'] as int,
      pageSize: data['pageSize'] as int,
      hasNext: data['hasNext'] as bool,
      hasPrevious: data['hasPrevious'] as bool,
    );
  }

  // Métodos auxiliares (usando datos dummy hasta implementar GraphQL)
  Pay? getPaymentById(String id) {
    // TODO: Implementar query GraphQL getPayById
    // Por ahora retorna null para usar fallback en las páginas
    return null;
  }

  List<Pay> getPaymentByUserId(String userId) {
    // TODO: Implementar query GraphQL getPaymentsByUserId
    // Por ahora retorna lista vacía para usar fallback en las páginas
    return [];
  }

  Future<PaymentStats> getPaymentsStats() async {
    final result = await _query(
      QueryOptions(
        document: gql('''
          query GetPaymentsStats {
            getPaymentsStats {
              totalApprovedPayments
              totalPendingPayments
              totalRejectedPayments
            }
          }
        '''),
      ),
    );

    if (result.hasException) throw result.exception!;

    final data = result.data!['getPaymentsStats'] as Map<String, dynamic>;
    return PaymentStats.fromJson(data);
  }

  //TODO ver los metodos si realmente estan correctos para conectar con GrahpQL

  PayRepository({GraphQLClient? graphQLClient})
    : _clientOverride = graphQLClient;

  final GraphQLClient? _clientOverride;

  Future<QueryResult> _query(QueryOptions options) {
    final override = _clientOverride;
    if (override != null) return override.query(options);
    return GraphQLClientFactory.client.query(options);
  }

  Future<QueryResult> _mutate(MutationOptions options) {
    final override = _clientOverride;
    if (override != null) return override.mutate(options);
    return GraphQLClientFactory.client.mutate(options);
  }

  // TODO: Descomentar cuando se conecte al backend real
  /*
  @override
  Future<PayPage> getAllPays({
    int page = 0,
    int size = 10,
    PayFilterInput? filters,
  }) async {
    final result = await _query(
      QueryOptions(
        document: gql('''
          query GetAllPays(\$page: Int!, \$size: Int!, \$filters: PayFilterInput) {
            getAllPays(page: \$page, size: \$size, filters: \$filters) {
              content {
                id
                fileName
                fileUrl
                date
                time
                amount
                state
              }
              totalElements
              totalPages
              pageNumber
              pageSize
              hasNext
              hasPrevious
            }
          }
        '''),
        variables: {'page': page, 'size': size, 'filters': filters?.toJson()},
      ),
    );

    if (result.hasException) throw result.exception!;

    final response = PaginatedPayResponse.fromJson(
      result.data!['getAllPays'] as Map<String, dynamic>,
    );
    return PayPage(
      content: response.content
          .map((model) => Pay.fromJson(model.toJson()))
          .toList(),
      totalElements: response.totalElements,
      totalPages: response.totalPages,
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }
  */

  @override
  Future<Pay> createPay(CreatePayInput input) async {
    final result = await _mutate(
      MutationOptions(
        document: gql('''
          mutation CreatePay(\$dueId: ID!, \$input: CreatePayInput!) {
            createPay(dueId: \$dueId, input: \$input) {
              id
              fileName
              fileUrl
              date
              time
              amount
              state
            }
          }
        '''),
        variables: input.toJson(),
      ),
    );

    if (result.hasException) throw result.exception!;

    final model = PayResponseModel.fromJson(
      result.data!['createPay'] as Map<String, dynamic>,
    );
    return Pay.fromJson(model.toJson()); // To entity //TODO
  }

  // Implementa updatePay, validatePay, rejectPay similares
  // Ej para validatePay:
  @override
  Future<Pay> validatePay(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql('''
          mutation ValidatePay(\$id: ID!) {
            validatePay(id: \$id) {
              id
              # ... all fields
            }
          }
        '''),
        variables: {'id': id},
      ),
    );
    throw UnimplementedError(); //TODO
    // Similar parsing...
  }

  @override
  Future<Pay?> getPayById(String id) {
    // TODO: implement getPayById
    throw UnimplementedError();
  }

  @override
  Future<Pay> rejectPay(String id) {
    // TODO: implement rejectPay
    throw UnimplementedError();
  }

  @override
  Future<Pay> updatePay(UpdatePayInput input) {
    // TODO: implement updatePay
    throw UnimplementedError();
  }

  // Agrega getPayById, etc.
}
