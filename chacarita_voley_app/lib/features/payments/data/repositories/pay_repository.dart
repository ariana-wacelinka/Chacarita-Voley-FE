import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/payment_stats.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/update_pay_input.dart';
import 'package:chacarita_voley_app/features/payments/domain/repositories/pay_repository_interface.dart';
import '../../domain/entities/create_pay_input.dart';
import '../../domain/entities/pay_page.dart';
import '../../domain/entities/pay_filter_input.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';

class PayRepository implements PayRepositoryInterface {
  // Datos dummy eliminados - ahora usa GraphQL real

  // Caché de pagos para búsqueda por ID
  final Map<String, Pay> _paysCache = {};

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
                createdAt
                updateAt
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

    final pays = (data['content'] as List)
        .map((json) => Pay.fromJson(json as Map<String, dynamic>))
        .toList();

    // Actualizar caché
    for (final pay in pays) {
      _paysCache[pay.id] = pay;
    }

    return PayPage(
      content: pays,
      totalElements: data['totalElements'] as int,
      totalPages: data['totalPages'] as int,
      pageNumber: data['pageNumber'] as int,
      pageSize: data['pageSize'] as int,
      hasNext: data['hasNext'] as bool,
      hasPrevious: data['hasPrevious'] as bool,
    );
  }

  /// Nueva query para obtener pagos de un jugador específico con filtros y paginado
  Future<PayPage> getPaysByPlayerId({
    required String playerId,
    int page = 0,
    int size = 10,
    String? dateFrom,
    String? dateTo,
  }) async {
    final Map<String, dynamic> filtersMap = {'playerId': playerId};

    if (dateFrom != null && dateFrom.isNotEmpty) {
      filtersMap['dateFrom'] = dateFrom;
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      filtersMap['dateTo'] = dateTo;
    }

    final result = await _query(
      QueryOptions(
        document: gql('''
          query GetPaysByPlayerId(\$page: Int!, \$size: Int!, \$filters: PayFilterInput!) {
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
                createdAt
                updateAt
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
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) throw result.exception!;

    final data = result.data!['getAllPays'] as Map<String, dynamic>;

    final pays = (data['content'] as List)
        .map((json) => Pay.fromJson(json as Map<String, dynamic>))
        .toList();

    // Actualizar caché
    for (final pay in pays) {
      _paysCache[pay.id] = pay;
    }

    return PayPage(
      content: pays,
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
    // Buscar en caché primero
    if (_paysCache.containsKey(id)) {
      return _paysCache[id];
    }
    return null;
  }

  List<Pay> getPaymentByUserId(String userId) {
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
                createdAt
                updateAt
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
              state
              amount
              date
              fileName
              fileUrl
              createdAt
              updateAt
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
        '''),
        variables: input.toJson(),
      ),
    );

    if (result.hasException) {
      print('❌ ERROR en createPay: ${result.exception}');
      if (result.exception?.graphqlErrors != null) {
        print('   - GraphQL Errors: ${result.exception!.graphqlErrors}');
      }
      if (result.exception?.linkException != null) {
        print('   - Link Exception: ${result.exception!.linkException}');
      }
      throw result.exception!;
    }

    final payData = result.data!['createPay'] as Map<String, dynamic>;
    final newPay = Pay.fromJson(payData);

    // Agregar a caché
    _paysCache[newPay.id] = newPay;

    return newPay;
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
              state
              amount
              date
              fileName
              fileUrl
              createdAt
              updateAt
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
        '''),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payData = result.data!['validatePay'] as Map<String, dynamic>;
    final validatedPay = Pay.fromJson(payData);

    // Actualizar caché
    _paysCache[validatedPay.id] = validatedPay;

    return validatedPay;
  }

  @override
  Future<Pay?> getPayById(String id) async {
    try {
      final result = await _query(
        QueryOptions(
          document: gql('''
            query GetPayById(\$id: ID!) {
              getPayById(id: \$id) {
                id
                state
                amount
                date
                fileName
                fileUrl
                createdAt
                updateAt
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
          '''),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        return null;
      }

      final payData = result.data?['getPayById'];
      if (payData == null) return null;

      return Pay.fromJson(payData as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Pay> rejectPay(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql('''
          mutation RejectPay(\$id: ID!) {
            rejectPay(id: \$id) {
              id
              state
              amount
              date
              fileName
              fileUrl
              createdAt
              updateAt
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
        '''),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payData = result.data!['rejectPay'] as Map<String, dynamic>;
    final rejectedPay = Pay.fromJson(payData);

    // Actualizar caché
    _paysCache[rejectedPay.id] = rejectedPay;

    return rejectedPay;
  }

  @override
  Future<Pay> updatePay(UpdatePayInput input) async {
    final inputMap = {
      if (input.fileName != null) 'fileName': input.fileName,
      if (input.fileUrl != null) 'fileUrl': input.fileUrl,
      if (input.amount != null) 'amount': input.amount,
      if (input.date != null) 'date': input.date,
    };

    final result = await _mutate(
      MutationOptions(
        document: gql('''
          mutation UpdatePay(\$id: ID!, \$input: UpdatePayInput!) {
            updatePay(id: \$id, input: \$input) {
              id
              state
              amount
              date
              fileName
              fileUrl
              createdAt
              updateAt
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
        '''),
        variables: {'id': input.id, 'input': inputMap},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payData = result.data!['updatePay'] as Map<String, dynamic>;
    final updatedPay = Pay.fromJson(payData);

    // Actualizar caché
    _paysCache[updatedPay.id] = updatedPay;

    return updatedPay;
  }

  @override
  Future<Pay> setPendingPay(String id) async {
    final result = await _mutate(
      MutationOptions(
        document: gql('''
          mutation SetPendingPay(\$id: ID!) {
            setPendingPay(id: \$id) {
              id
              state
              amount
              date
              fileName
              fileUrl
              createdAt
              updateAt
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
        '''),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final payData = result.data!['setPendingPay'] as Map<String, dynamic>;
    final updatedPay = Pay.fromJson(payData);

    // Actualizar caché
    _paysCache[updatedPay.id] = updatedPay;

    return updatedPay;
  }

  // Agrega getPayById, etc.
}
