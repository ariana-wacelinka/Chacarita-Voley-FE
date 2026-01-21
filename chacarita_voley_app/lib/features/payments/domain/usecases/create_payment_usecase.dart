import 'package:chacarita_voley_app/features/payments/domain/entities/payment.dart';
import '../repositories/payments_repository_interface.dart';

class CreatePaymentUseCase {
  final PaymentsRepositoryInterface repository;

  CreatePaymentUseCase(this.repository);

  Future<Payment> execute(Payment payment) async {
    return await repository.createPayment(payment);
  }
}
