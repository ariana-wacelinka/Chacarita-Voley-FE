import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/update_pay_input.dart';
import 'package:chacarita_voley_app/features/payments/domain/repositories/pay_repository_interface.dart';

import '../../domain/entities/create_pay_input.dart';
import '../../domain/entities/pay_state.dart';

import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../../domain/entities/pay.dart';
import '../../domain/entities/pay_page.dart';
import '../../domain/entities/pay_filter_input.dart';
import '../../domain/repositories/pay_repository_interface.dart';
import '../models/pay_response_model.dart';

class PayRepository implements PayRepositoryInterface {
  static final List<Pay> _payments = [
    // PAGOS validatedS
    Pay(
      id: '01',
      userId: '01',
      userName: 'Jose Juan',
      dni: '12345678',
      paymentDate: DateTime.now().subtract(Duration(days: 1)),
      sentDate: DateTime.now().subtract(Duration(hours: 2)),
      amount: 20.00,
      status: PayState.validated,
      comprobantePath: 'comprobanteJose.pdf',
    ),
    Pay(
      id: '02',
      userId: '02',
      userName: 'María González',
      dni: '87654321',
      paymentDate: DateTime.now().subtract(Duration(days: 2)),
      sentDate: DateTime.now().subtract(Duration(days: 1)),
      amount: 35.50,
      status: PayState.validated,
      comprobantePath: 'comprobanteMaria.pdf',
    ),
    Pay(
      id: '03',
      userId: '03',
      userName: 'Carlos Rodríguez',
      dni: '11223344',
      paymentDate: DateTime.now().subtract(Duration(days: 3)),
      sentDate: DateTime.now().subtract(Duration(days: 2)),
      amount: 15.75,
      status: PayState.validated,
    ),

    // PAGOS pendingS
    Pay(
      id: '04',
      userId: '04',
      userName: 'Ana Martínez',
      dni: '22334455',
      paymentDate: DateTime.now().subtract(Duration(days: 5)),
      sentDate: DateTime.now().subtract(Duration(days: 7)),
      amount: 50.00,
      status: PayState.pending,
      comprobantePath: 'comprobanteAna.pdf',
    ),
    Pay(
      id: '05',
      userId: '05',
      userName: 'Luis Fernández',
      dni: '33445566',
      paymentDate: DateTime.now().subtract(Duration(days: 8)),
      sentDate: DateTime.now().subtract(Duration(days: 10)),
      amount: 28.90,
      status: PayState.pending,
    ),

    // PAGOS rejectedS
    Pay(
      id: '06',
      userId: '06',
      userName: 'Diego Sánchez',
      dni: '55667788',
      paymentDate: DateTime.now().subtract(Duration(days: 4)),
      sentDate: DateTime.now().subtract(Duration(days: 5)),
      amount: 18.00,
      status: PayState.rejected,
      notes: 'Comprobante ilegible',
    ),
    Pay(
      id: '07',
      userId: '07',
      userName: 'Laura Torres',
      dni: '66778899',
      paymentDate: DateTime.now().subtract(Duration(days: 6)),
      sentDate: DateTime.now().subtract(Duration(days: 8)),
      amount: 25.60,
      status: PayState.rejected,
      notes: 'Monto incorrecto',
    ),
  ];

  //TODO de aca hasta el otro ToDo de abajo
  @override
  List<Pay> getPayments() {
    return List<Pay>.from(_payments);
  }

  @override
  Pay? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  @override //TODO
  List<Pay> getPaymentByUserId(String id) {
    try {
      return List<Pay>.from(_payments.where((payments) => payments.id == id));
    } catch (e) {
      return <Pay>[];
    }
  }

  @override
  Future<Pay> createPayment(Pay payment) async {
    // Simula delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    final newPayment = payment.copyWith(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
    );
    _payments.add(newPayment);
    return newPayment;
  }

  @override
  Future<Pay> updatePayment(Pay payment) async {
    // Simula delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index == -1) {
      throw Exception('Payment not found');
    }

    _payments[index] = payment;
    return payment;
  }

  @override
  Future<void> deletePayment(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _payments.removeWhere((payment) => payment.id == id);
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
      // Map model to entity
      totalElements: response.totalElements,
      totalPages: response.totalPages,
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  @override
  Future<Pay> createPay(CreatePayInput input) async {
    final result = await _mutate(
      MutationOptions(
        document: gql('''
          mutation CreatePay(\$input: CreatePayInput!) {
            createPay(input: \$input) {
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
        variables: {'input': input.toJson()},
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
