import '../entities/pay.dart';
import '../entities/create_pay_input.dart';
import '../entities/update_pay_input.dart';
import '../../../users/domain/entities/user.dart';

class PayMapper {
  static CreatePayInput toCreateInput(Pay pay, User user) {
    if (user.currentDue == null) {
      throw ArgumentError('User must have a currentDue to create a payment');
    }

    return CreatePayInput(
      dueId: user.currentDue!.id,
      fileName: pay.fileName,
      fileUrl: pay.fileUrl,
      date: pay.date,
      amount: pay.amount,
      state: pay.status.name.toUpperCase(),
    );
  }

  static UpdatePayInput toUpdateInput(Pay pay) {
    return UpdatePayInput(
      id: pay.id,
      fileName: pay.fileName,
      fileUrl: pay.fileUrl,
      date: pay.date,
      time: pay.time,
      amount: pay.amount,
      state: pay.status.name.toUpperCase(),
    );
  }
}
