import '../entities/payment.dart';
import '../repositories/payments_repository_interface.dart';

class GetPaymentByIdUseCase {
  final PaymentsRepositoryInterface repository;

  GetPaymentByIdUseCase(this.repository);

  Future<Payment?> execute(String paymentId) async {
    return await repository.getPaymentById(paymentId);
  }
}
