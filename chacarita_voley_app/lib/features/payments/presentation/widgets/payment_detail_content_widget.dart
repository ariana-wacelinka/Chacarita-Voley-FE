import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/payment.dart';

class PaymentDetailContent extends StatelessWidget {
  final Payment payment;

  const PaymentDetailContent({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección Detalles del Pago
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.card1,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles del Pago',
                  style: TextStyle(
                    color: tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.access_time_outlined,
                  label: 'Hora:',
                  value: timeFormat.format(payment.paymentDate),
                  context: context,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha del Pago:',
                  value: dateFormat.format(payment.paymentDate),
                  context: context,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sección Comprobante de Pago
          GestureDetector(
            onTap: () {
              // Lógica para descargar o ver comprobante
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Descargando ${payment.comprobantePath ?? 'comprobante'}',
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.card1,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tokens.stroke),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined, color: tokens.gray),
                      const SizedBox(width: 12),
                      Text(
                        'Comprobante de Pago',
                        style: TextStyle(
                          color: tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.download_outlined, color: tokens.gray),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección Estado del Pago
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.card1,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.stroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado del Pago',
                  style: TextStyle(
                    color: tokens.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusRow(
                  label: 'A validar',
                  subtitle: 'Pendiente de revisión',
                  isSelected:
                      payment.status ==
                      PaymentStatus.pendiente, // Asumiendo basado en status
                  context: context, //TODO es asi esto o se puede mejorar
                ),
                // Agrega más si necesitas mostrar todos, pero en imagen solo uno seleccionado
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fila para detalles (hora/fecha)
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context, //TODO Es asi esto o se puede mejorar?
  }) {
    return Row(
      children: [
        Icon(icon, color: context.tokens.gray),
        const SizedBox(width: 12),
        Text(
          '$label $value',
          style: TextStyle(color: context.tokens.text, fontSize: 16),
        ),
      ],
    );
  }

  // Fila para estado (con radio-like)
  Widget _buildStatusRow({
    required String label,
    required String subtitle,
    required bool isSelected,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          color: isSelected ? context.tokens.redToRosita : context.tokens.gray,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: context.tokens.gray, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
