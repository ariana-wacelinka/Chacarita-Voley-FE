import 'package:intl/intl.dart';
import '../entities/pay.dart';
import '../entities/create_pay_input.dart';
import '../entities/update_pay_input.dart';
class PayMapper {
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static CreatePayInput toCreateInput(Pay pay, String dueId) {
    // Convertir fecha de formato display (dd/MM/yyyy) a formato ISO (yyyy-MM-dd)
    String isoDate;
    try {
      final parsedDate = _displayFormat.parse(pay.date);
      isoDate = _isoFormat.format(parsedDate);
    } catch (e) {
      // Si ya está en formato ISO o es inválido, usar tal cual
      isoDate = pay.date;
    }

    return CreatePayInput(
      dueId: dueId,
      fileName: pay.fileName,
      fileUrl: pay.fileUrl,
      date: isoDate,
      amount: pay.amount,
      state: pay.status.name.toUpperCase(),
    );
  }

  static UpdatePayInput toUpdateInput(Pay pay) {
    // Convertir fecha de formato display (dd/MM/yyyy) a formato ISO (yyyy-MM-dd)
    String isoDate;
    try {
      final parsedDate = _displayFormat.parse(pay.date);
      isoDate = _isoFormat.format(parsedDate);
    } catch (e) {
      // Si ya está en formato ISO o es inválido, usar tal cual
      isoDate = pay.date;
    }

    return UpdatePayInput(
      id: pay.id,
      fileName: pay.fileName,
      fileUrl: pay.fileUrl,
      date: isoDate,
      amount: pay.amount,
    );
  }
}
