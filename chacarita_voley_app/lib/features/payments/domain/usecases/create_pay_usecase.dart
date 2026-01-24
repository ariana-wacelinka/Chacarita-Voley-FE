import '../entities/create_pay_input.dart';
import '../entities/pay.dart';
import '../repositories/pay_repository_interface.dart';

class CreatePayUseCase {
  final PayRepositoryInterface repository;

  CreatePayUseCase(this.repository);

  Future<Pay> execute(CreatePayInput input) async {
    return await repository.createPay(input);
  }
}
