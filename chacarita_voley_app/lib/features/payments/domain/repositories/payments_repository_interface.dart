import 'package:chacarita_voley_app/features/payments/domain/entities/payment.dart';

abstract class PaymentsRepositoryInterface {
  List<Payment> getPayments();

  Payment? getPaymentById(String id);

  Future<Payment> createPayment(Payment payment);

  Future<Payment> updatePayment(Payment payment);

  Future<void> deletePayment(String id);
}
