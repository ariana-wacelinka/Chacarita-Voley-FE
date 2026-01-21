import '../entities/payment.dart';
import '../repositories/payments_repository_interface.dart';

class GetAllPaymentsUseCase {
  final PaymentsRepositoryInterface repository;

  GetAllPaymentsUseCase(this.repository);

  Future<List<Payment>> execute() async {
    return await repository.getPayments();
  }
}
