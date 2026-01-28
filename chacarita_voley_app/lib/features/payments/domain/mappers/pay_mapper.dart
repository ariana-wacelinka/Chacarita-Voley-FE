import '../entities/pay.dart';
import '../entities/create_pay_input.dart';
import 'package:intl/intl.dart';

import '../entities/update_pay_input.dart'; // Para formateo date/time

class PayMapper {
  static CreatePayInput toCreateInput(Pay pay) {
    return CreatePayInput(
      fileName: pay.fileName,
      fileUrl: pay.fileUrl,
      date: pay.date,
      time: pay.time,
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

  // add more: e.g., static Pay fromResponseModel(PayResponseModel model) { ... }
}
