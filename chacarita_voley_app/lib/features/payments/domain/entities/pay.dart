import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:flutter/foundation.dart'; // Para @immutable si quieres

@immutable
class Pay {
  final String? id; // ID único para editar/detalle/historial
  final String? userId;
  final String userName; // Nombre completo para display
  final String dni; // DNI para filtros/búsquedas
  final DateTime paymentDate; // Fecha y hora del pago (incluye time)
  final DateTime sentDate; // Fecha de envío/subida
  final DateTime?
  dueDate; // Fecha de vencimiento (para calcular estado cuota si derivado)
  final double amount; // Monto
  final PayState status; // Estado del pago individual
  final String?
  comprobantePath; // Path/URL del archivo comprobante (PDF/imagen)
  final String? notes; // Notas opcionales (ej: razón de rechazo)

  const Pay({
    this.id,
    required this.userId,
    required this.userName,
    required this.dni,
    required this.paymentDate,
    required this.sentDate,
    this.dueDate,
    required this.amount,
    required this.status,
    this.comprobantePath,
    this.notes,
  });

  // Método copyWith para updates fáciles (útil en edición)
  Pay copyWith({
    String? id,
    String? userId,
    String? userName,
    String? dni,
    DateTime? paymentDate,
    DateTime? sentDate,
    DateTime? dueDate,
    double? amount,
    PayState? status,
    String? comprobantePath,
    String? notes,
  }) {
    return Pay(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      dni: dni ?? this.dni,
      paymentDate: paymentDate ?? this.paymentDate,
      sentDate: sentDate ?? this.sentDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      comprobantePath: comprobantePath ?? this.comprobantePath,
      notes: notes ?? this.notes,
    );
  }

  // Factory fromJson (para persistencia, similar a User)
  factory Pay.fromJson(Map<String, dynamic> json) {
    return Pay(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String,
      dni: json['dni'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      sentDate: DateTime.parse(json['sentDate'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      amount: (json['amount'] as num).toDouble(),
      status: PayState.values.firstWhere(
        (e) => e.name == (json['status'] as String),
      ),
      comprobantePath: json['comprobantePath'] as String?,
      notes: json['notes'] as String?,
    );
  }

  // toJson (para persistencia)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'dni': dni,
      'paymentDate': paymentDate.toIso8601String(),
      'sentDate': sentDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'amount': amount,
      'status': status.name,
      'comprobantePath': comprobantePath,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Payment(id: $id, userId: $userId, userName: $userName, dni: $dni, paymentDate: $paymentDate, sentDate: $sentDate, dueDate: $dueDate, amount: $amount, status: $status, comprobantePath: $comprobantePath, notes: $notes)';
  }
}
