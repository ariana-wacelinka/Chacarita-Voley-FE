import '../entities/create_pay_input.dart';
import '../entities/pay.dart';

CreatePayInput buildCreatePayInput({
  required Pay newPay,
  required String dueId,
  required String isoDate,
}) {
  return CreatePayInput(
    dueId: dueId,
    date: isoDate,
    amount: newPay.amount,
    state: newPay.status.name.toUpperCase(),
  );
}
