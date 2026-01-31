import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import '../entities/update_pay_input.dart';
import '../repositories/pay_repository_interface.dart';

class UpdatePaymentUseCase {
  final PayRepositoryInterface repository;

  UpdatePaymentUseCase(this.repository);

  Future<Pay> execute(UpdatePayInput pay) async {
    return await repository.updatePay(pay);
  }
}
