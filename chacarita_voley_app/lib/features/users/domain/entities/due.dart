enum DueState { PAID, PENDING, OVERDUE }

enum PayState { PENDING, APPROVED, REJECTED }

class Pay {
  final String? id;
  final String? date;
  final double? amount;
  final PayState state;
  final String? fileUrl;
  final String? fileName;
  final String? time;

  Pay({
    this.id,
    this.date,
    this.amount,
    required this.state,
    this.fileUrl,
    this.fileName,
    this.time,
  });

  factory Pay.fromJson(Map<String, dynamic> json) {
    return Pay(
      id: json['id'] as String?,
      date: json['date'] as String?,
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      state: PayState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => PayState.PENDING,
      ),
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      time: json['time'] as String?,
    );
  }
}

class CurrentDue {
  final String id;
  final DueState state;
  final String period;
  final double? amount;
  final Pay? pay;

  CurrentDue({
    required this.id,
    required this.state,
    required this.period,
    this.amount,
    this.pay,
  });

  factory CurrentDue.fromJson(Map<String, dynamic> json) {
    return CurrentDue(
      id: json['id'] as String,
      state: DueState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => DueState.PENDING,
      ),
      period: json['period'] as String,
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      pay: json['pay'] != null
          ? Pay.fromJson(json['pay'] as Map<String, dynamic>)
          : null,
    );
  }

  double get effectiveAmount => amount ?? pay?.amount ?? 0.0;

  String get formattedPeriod {
    try {
      final parts = period.split('-');
      if (parts.length != 2) return period;
      final year = parts[0];
      final month = int.parse(parts[1]);
      const months = [
        '',
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];
      return '${months[month]} $year';
    } catch (e) {
      return period;
    }
  }
}
