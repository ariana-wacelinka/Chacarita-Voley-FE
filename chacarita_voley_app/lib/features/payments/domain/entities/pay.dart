import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:flutter/foundation.dart'; // Para @immutable si quieres

@immutable
class Pay {
  final String id;
  final PayState status; // state en backend
  final double amount;
  final String date; // "2025-01-20" formato
  final String time; // "20:06:07.491" formato
  final String fileName;
  final String fileUrl;

  // Campos opcionales que pueden venir del player asociado
  final String? userName; // Del player si está disponible
  final String? dni; // Del player si está disponible
  final String? notes; // Notas opcionales

  const Pay({
    required this.id,
    required this.status,
    required this.amount,
    required this.date,
    required this.time,
    required this.fileName,
    required this.fileUrl,
    this.userName,
    this.dni,
    this.notes,
  });

  DateTime get paymentDate => DateTime.parse('$date $time');
  DateTime get sentDate => paymentDate; // Asumimos que es la misma

  Pay copyWith({
    String? id,
    PayState? status,
    double? amount,
    String? date,
    String? time,
    String? fileName,
    String? fileUrl,
    String? userName,
    String? dni,
    String? notes,
  }) {
    return Pay(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      userName: userName ?? this.userName,
      dni: dni ?? this.dni,
      notes: notes ?? this.notes,
    );
  }

  factory Pay.fromJson(Map<String, dynamic> json) {
    return Pay(
      id: json['id'] as String,
      status: PayState.values.firstWhere(
        (e) => e.name == (json['state'] as String? ?? json['status'] as String),
      ),
      amount: (json['amount'] as num).toDouble(),
      date: json['date'] as String,
      time: json['time'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      userName: json['userName'] as String?,
      dni: json['dni'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': status.name,
      'amount': amount,
      'date': date,
      'time': time,
      'fileName': fileName,
      'fileUrl': fileUrl,
      if (userName != null) 'userName': userName,
      if (dni != null) 'dni': dni,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  String toString() {
    return 'Pay(id: $id, status: $status, amount: $amount, date: $date, time: $time, fileName: $fileName, userName: $userName, dni: $dni)';
  }
}
