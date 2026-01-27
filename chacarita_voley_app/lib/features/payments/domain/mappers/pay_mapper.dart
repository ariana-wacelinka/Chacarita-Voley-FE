import '../entities/pay.dart';
import '../entities/create_pay_input.dart';
import 'package:intl/intl.dart';

import '../entities/update_pay_input.dart'; // Para formateo date/time

class PayMapper {
  static CreatePayInput toCreateInput(Pay pay) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    return CreatePayInput(
      //Review
      fileName: pay.userName + pay.dni,
      //Ajusta fields reales de Pay
      fileUrl: pay.comprobantePath,
      date: dateFormat.format(pay.paymentDate),
      time: timeFormat.format(pay.paymentDate),
      amount: pay.amount,
      state: pay.status.name.toUpperCase(),
    );
  }

  static UpdatePayInput toUpdateInput(Pay pay) {
    final dateFormat = DateFormat(
      'yyyy-MM-dd',
    ); //Ajusta al formato esperado por la API
    final timeFormat = DateFormat('HH:mm');

    //Validaciones básicas para update
    if (pay.id == null) {
      throw ArgumentError('id es requerido para actualizar un PayInput');
    }
    //valida si cambios son válidos (e.g., amount > 0 si se actualiza)
    if (pay.amount != null && pay.amount <= 0) {
      throw ArgumentError('amount debe ser mayor a 0 si se proporciona');
    }

    return UpdatePayInput(
      id: pay.id!,
      //Review
      fileName: pay.userName + pay.dni,
      fileUrl: pay.comprobantePath,
      date: pay.paymentDate != null ? dateFormat.format(pay.paymentDate) : null,
      time: pay.paymentDate != null ? timeFormat.format(pay.paymentDate) : null,
      amount: pay.amount,
      state: pay.status.name.toUpperCase(), // Convertir enum a string
    );
  }

  // add more: e.g., static Pay fromResponseModel(PayResponseModel model) { ... }
}
