import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../domain/entities/pay.dart';
import '../../data/repositories/pay_repository.dart';

class PaymentDetailContent extends StatefulWidget {
  final Pay payment;
  final VoidCallback? onPaymentUpdated;

  const PaymentDetailContent({
    super.key,
    required this.payment,
    this.onPaymentUpdated,
  });

  @override
  State<PaymentDetailContent> createState() => _PaymentDetailContentState();
}

class _PaymentDetailContentState extends State<PaymentDetailContent> {
  bool _isDownloading = false;
  final _payRepository = PayRepository();

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
                    Expanded(
                      child: Text(
                        'Detalles del Pago',
                        style: TextStyle(
                          color: tokens.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Symbols.more_vert,
                        color: tokens.text,
                        size: 24,
                      ),
                      onSelected: (value) {
                        if (value == 'pending') {
                          _setPendingPay();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'pending',
                          child: Row(
                            children: [
                              Icon(
                                Symbols.schedule,
                                color: tokens.text,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Pasar a pendiente nuevamente',
                                  maxLines: 2,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: tokens.text,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.access_time_outlined,
                  label: 'Hora:',
                  value:
                      (widget.payment.updateAt ??
                              widget.payment.createdAt ??
                              '')
                          .substring(11, 16),
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
          GestureDetector(
            onTap: (widget.payment.fileName?.isNotEmpty ?? false)
                ? _downloadReceipt
                : null,
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
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: tokens.text,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Comprobante de Pago',
                                style: TextStyle(
                                  color: tokens.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.payment.fileName?.isNotEmpty ??
                                  false) ...[
                                const SizedBox(height: 8),
                                Text(
                                  widget.payment.fileName!.split('/').last,
                                  style: TextStyle(
                                    color: tokens.gray,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isDownloading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(tokens.text),
                      ),
                    )
                  else
                    Icon(
                      (widget.payment.fileName?.isNotEmpty ?? false)
                          ? Icons.file_download
                          : Icons.file_download_off,
                      color: (widget.payment.fileName?.isNotEmpty ?? false)
                          ? tokens.text
                          : tokens.gray,
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

  Future<void> _downloadReceipt() async {
    setState(() => _isDownloading = true);

    try {
      await FileUploadService.downloadPaymentReceiptWithNotification(
        paymentId: widget.payment.id,
        fileName: widget.payment.fileName ?? 'comprobante.pdf',
      );

      if (mounted) {
        final topPadding = MediaQuery.of(context).padding.top;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comprobante descargado exitosamente'),
            backgroundColor: context.tokens.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final topPadding = MediaQuery.of(context).padding.top;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar comprobante: $e'),
            backgroundColor: context.tokens.redToRosita,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _setPendingPay() async {
    try {
      await _payRepository.setPendingPay(widget.payment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pago actualizado a pendiente'),
            backgroundColor: context.tokens.green,
          ),
        );

        // Notificar a la página padre que el pago se actualizó
        widget.onPaymentUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar pago: $e'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
    }
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
