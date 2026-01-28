import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/update_pay_input.dart';
import 'package:chacarita_voley_app/features/payments/domain/repositories/pay_repository_interface.dart';
import '../../domain/entities/create_pay_input.dart';
import '../../domain/entities/pay_state.dart';
import '../../domain/entities/pay_page.dart';
import '../../domain/entities/pay_filter_input.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../models/pay_response_model.dart';

class PayRepository implements PayRepositoryInterface {
  static final List<Pay> _payments = [
    // PAGOS PENDIENTES
    Pay(
      id: '1',
      status: PayState.pending,
      amount: 5000.0,
      date: '2025-01-20',
      time: '20:01:00.076',
      fileName: 'receipts/1/6264c1a6-38a2-4b57-9bc9-e96da9387b0d.pdf',
      fileUrl:
          'https://chacarita.blob.core.windows.net/comprobantes/receipts%2F1%2F6264c1a6-38a2-4b57-9bc9-e96da9387b0d.pdf',
      userName: 'Juan Pérez',
      dni: '12345678',
    ),
    Pay(
      id: '3',
      status: PayState.pending,
      amount: 15000.5,
      date: '2025-01-20',
      time: '20:06:07.491',
      fileName: 'transferencia_enrique.pdf',
      fileUrl: 'https://ejemplo.com/comprobantes/enrique_cruz_enero.png',
      userName: 'Enrique Cruz',
      dni: '87654321',
    ),
    Pay(
      id: '4',
      status: PayState.pending,
      amount: 12000.0,
      date: '2025-01-19',
      time: '15:30:00.000',
      fileName: 'pago_ana.pdf',
      fileUrl: 'https://ejemplo.com/comprobantes/ana_enero.pdf',
      userName: 'Ana Martínez',
      dni: '22334455',
    ),

    // PAGOS RECHAZADOS
    Pay(
      id: '2',
      status: PayState.rejected,
      amount: 18500.0,
      date: '2025-01-18',
      time: '20:04:24.200',
      fileName: 'pago_mari_gonzales.pdf',
      fileUrl: 'https://ejemplo.com/comprobantes/mari_gonzales_enero.pdf',
      userName: 'María González',
      dni: '11223344',
      notes: 'Comprobante ilegible',
    ),
    Pay(
      id: '6',
      status: PayState.rejected,
      amount: 8000.0,
      date: '2025-01-17',
      time: '10:15:00.000',
      fileName: 'pago_diego.pdf',
      fileUrl: 'https://ejemplo.com/comprobantes/diego_enero.pdf',
      userName: 'Diego Sánchez',
      dni: '55667788',
      notes: 'Monto incorrecto',
    ),

    // PAGOS VALIDADOS
    Pay(
      id: '5',
      status: PayState.validated,
      amount: 10000.0,
      date: '2025-01-15',
      time: '14:20:00.000',
      fileName: 'pago_carlos.pdf',
      fileUrl: 'https://ejemplo.com/comprobantes/carlos_enero.pdf',
      userName: 'Carlos Rodríguez',
      dni: '33445566',
    ),
    Pay(
      id: '7',
      status: PayState.validated,
      amount: 9500.0,
      date: '2025-01-14',
      time: '11:00:00.000',
      fileName: 'pago_laura.pdf',
      fileUrl: 'https://ejemplo.com/comprobantes/laura_enero.pdf',
      userName: 'Laura Torres',
      dni: '66778899',
    ),
  ];

  //TODO de aca hasta el otro ToDo de abajo
  @override
  Future<PayPage> getAllPays({
    int page = 0,
    int size = 10,
    PayFilterInput? filters,
  }) async {
    // Simula delay de red
    await Future.delayed(const Duration(milliseconds: 300));

    // Aplicar filtros
    var filtered = List<Pay>.from(_payments);

    if (filters?.state != null) {
      filtered = filtered.where((p) => p.status == filters!.state).toList();
    }

    // Simular filtrado por fechas (simplificado)
    // En producción, esto lo haría el backend

    // Calcular paginación
    final totalElements = filtered.length;
    final totalPages = (totalElements / size).ceil();
    final startIndex = page * size;
    final endIndex = (startIndex + size).clamp(0, totalElements);

    final content = filtered.sublist(
      startIndex.clamp(0, totalElements),
      endIndex,
    );

    return PayPage(
      content: content,
      totalElements: totalElements,
      totalPages: totalPages,
      pageNumber: page,
      pageSize: size,
      hasNext: page < totalPages - 1,
      hasPrevious: page > 0,
    );
  }

  List<Pay> getPayments() {
    return List<Pay>.from(_payments);
  }

  Pay? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Pay> getPaymentByUserId(String id) {
    try {
      return List<Pay>.from(_payments.where((payments) => payments.id == id));
    } catch (e) {
      return <Pay>[];
    }
  }

  Future<Pay> createPayment(Pay payment) async {
    // Simula delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    final newPayment = payment.copyWith(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
    );
    _payments.add(newPayment);
    return newPayment;
  }

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
