import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';

import '../entities/create_pay_input.dart';
import '../entities/pay_filter_input.dart';
import '../entities/pay_page.dart';
import '../entities/update_pay_input.dart';

abstract class PayRepositoryInterface {
  Future<PayPage> getAllPays({
    int page = 0,
    int size = 10,
    PayFilterInput? filters,
  });

  Future<Pay?> getPayById(String id);

  Future<Pay> createPay(CreatePayInput input);

  Future<Pay> updatePay(UpdatePayInput input);

  Future<Pay> validatePay(String id);

  Future<Pay> rejectPay(String id);

  Future<Pay> setPendingPay(String id);
}
