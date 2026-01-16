import 'package:chacarita_voley_app/features/payments/domain/entities/payment.dart';

import '../repositories/payments_repository_interface.dart';

class UpdatePaymentUseCase {
  final PaymentsRepositoryInterface repository;

  UpdatePaymentUseCase(this.repository);

  Future<Payment> execute(Payment payment) async {
    return await repository.updatePayment(payment);
  }
}
