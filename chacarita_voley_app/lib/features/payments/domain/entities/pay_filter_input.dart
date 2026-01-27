import 'pay_state.dart';

class PayFilterInput {
  final String? fileName;
  final String? fileUrl;
  final String? date;
  final String? time;
  final double? amount;
  final String? dateFrom;
  final String? dateTo;
  final String? timeFrom;
  final String? timeTo;
  final double? amountFrom;
  final double? amountTo;
  final PayState? state;

  const PayFilterInput({
    this.fileName,
    this.fileUrl,
    this.date,
    this.time,
    this.amount,
    this.dateFrom,
    this.dateTo,
    this.timeFrom,
    this.timeTo,
    this.amountFrom,
    this.amountTo,
    this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      if (fileName != null) 'fileName': fileName,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (amount != null) 'amount': amount,
      if (dateFrom != null) 'dateFrom': dateFrom,
      if (dateTo != null) 'dateTo': dateTo,
      if (timeFrom != null) 'timeFrom': timeFrom,
      if (timeTo != null) 'timeTo': timeTo,
      if (amountFrom != null) 'amountFrom': amountFrom,
      if (amountTo != null) 'amountTo': amountTo,
      if (state != null) 'state': state!.name.toUpperCase(),
      // Asumiendo uppercase en API
    };
  }
}
