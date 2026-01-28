import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';

class PaymentDetailContent extends StatefulWidget {
  final Pay payment;

  const PaymentDetailContent({super.key, required this.payment});

  @override
  State<PaymentDetailContent> createState() => _PaymentDetailContentState();
}

class _PaymentDetailContentState extends State<PaymentDetailContent> {
  bool _isDownloaded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

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
                Row(
                  children: [
                    Icon(
                      Icons.credit_card_outlined,
                      color: tokens.text,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Detalles del Pago',
                      style: TextStyle(
                        color: tokens.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.access_time_outlined,
                  label: 'Hora:',
                  value: widget.payment.time.substring(0, 5),
                  context: context,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha del Pago:',
                  value: DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(widget.payment.date)),
                  context: context,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sección Comprobante de Pago
          // Sección Comprobante de Pago
          GestureDetector(
            onTap: () {
              // Lógica para descargar o ver comprobante
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Descargando ${widget.payment.fileName}'),
                ),
              );
              setState(() {
                _isDownloaded = true;
              });
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
                      Icon(
                        Icons.description_outlined,
                        color: tokens.text,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Comprobante de Pago',
                        style: TextStyle(
                          color: tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isDownloaded ? Icons.download_done : Icons.file_download,
                    color: tokens.text,
                  ),
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
                Row(
                  children: [
                    Icon(Icons.info_outline, color: tokens.text, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Estado del Pago',
                      style: TextStyle(
                        color: tokens.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusRow(
                  label: 'A validar',
                  subtitle: 'Pendiente de revisión',
                  isSelected: widget.payment.status == PayState.pending,
                  context: context,
                ),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.tokens.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.tokens.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.tokens.gray,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.access_time_outlined,
            color: context.tokens.gray,
            size: 20,
          ),
        ],
      ),
    );
  }
}
