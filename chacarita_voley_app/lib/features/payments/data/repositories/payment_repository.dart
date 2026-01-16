import 'package:chacarita_voley_app/features/payments/domain/entities/payment.dart';
import 'package:chacarita_voley_app/features/payments/domain/repositories/payments_repository_interface.dart';

class PaymentRepository implements PaymentsRepositoryInterface {
  static final List<Payment> _payments = [
    // PAGOS PENDIENTES
    Payment(
      id: '01',
      userName: 'Jose Juan',
      dni: '12345678',
      paymentDate: DateTime.now().subtract(Duration(days: 1)),
      sentDate: DateTime.now().subtract(Duration(hours: 2)),
      amount: 20.00,
      status: PaymentStatus.pendiente,
      comprobantePath: 'comprobanteJose.pdf',
    ),
    Payment(
      id: '02',
      userName: 'María González',
      dni: '87654321',
      paymentDate: DateTime.now().subtract(Duration(days: 2)),
      sentDate: DateTime.now().subtract(Duration(days: 1)),
      amount: 35.50,
      status: PaymentStatus.pendiente,
      comprobantePath: 'comprobanteMaria.pdf',
    ),
    Payment(
      id: '03',
      userName: 'Carlos Rodríguez',
      dni: '11223344',
      paymentDate: DateTime.now().subtract(Duration(days: 3)),
      sentDate: DateTime.now().subtract(Duration(days: 2)),
      amount: 15.75,
      status: PaymentStatus.pendiente,
    ),

    // PAGOS APROBADOS
    Payment(
      id: '04',
      userName: 'Ana Martínez',
      dni: '22334455',
      paymentDate: DateTime.now().subtract(Duration(days: 5)),
      sentDate: DateTime.now().subtract(Duration(days: 7)),
      amount: 50.00,
      status: PaymentStatus.aprobado,
      comprobantePath: 'comprobanteAna.pdf',
    ),
    Payment(
      id: '05',
      userName: 'Luis Fernández',
      dni: '33445566',
      paymentDate: DateTime.now().subtract(Duration(days: 8)),
      sentDate: DateTime.now().subtract(Duration(days: 10)),
      amount: 28.90,
      status: PaymentStatus.aprobado,
    ),

    // PAGOS RECHAZADOS
    Payment(
      id: '06',
      userName: 'Diego Sánchez',
      dni: '55667788',
      paymentDate: DateTime.now().subtract(Duration(days: 4)),
      sentDate: DateTime.now().subtract(Duration(days: 5)),
      amount: 18.00,
      status: PaymentStatus.rechazado,
      notes: 'Comprobante ilegible',
    ),
    Payment(
      id: '07',
      userName: 'Laura Torres',
      dni: '66778899',
      paymentDate: DateTime.now().subtract(Duration(days: 6)),
      sentDate: DateTime.now().subtract(Duration(days: 8)),
      amount: 25.60,
      status: PaymentStatus.rechazado,
      notes: 'Monto incorrecto',
    ),
  ];

  @override
  List<Payment> getPayments() {
    return List<Payment>.from(_payments);
  }

  @override
  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    // Simula delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    final newPayment = payment.copyWith(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
    );
    _payments.add(newPayment);
    return newPayment;
  }

  @override
  Future<Payment> updatePayment(Payment payment) async {
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
}
