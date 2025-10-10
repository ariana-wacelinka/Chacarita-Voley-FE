// Modelo de pago
class Payment {
  final String userName;
  final String dni;
  final DateTime paymentDate;
  final DateTime sentDate;
  final double amount;
  final String status; // 'Pendiente', 'Aprobado', 'Rechazado'

  Payment({
    required this.userName,
    required this.dni,
    required this.paymentDate,
    required this.sentDate,
    required this.amount,
    required this.status,
  });
}
