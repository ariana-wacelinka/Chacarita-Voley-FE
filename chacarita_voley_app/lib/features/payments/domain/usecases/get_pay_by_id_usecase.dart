import '../entities/pay.dart';
import '../repositories/pay_repository_interface.dart';

class GetPaymentByIdUseCase {
  final PayRepositoryInterface repository;

  GetPaymentByIdUseCase(this.repository);

  Future<Pay?> execute(String payId) async {
    return await repository.getPayById(payId);
  }
}
