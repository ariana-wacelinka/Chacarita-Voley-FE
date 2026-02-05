import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../domain/entities/pay.dart';
import '../../domain/entities/pay_state.dart';

class PaymentEditFormWidget extends StatefulWidget {
  final Pay payment;
  final DateFormat dateFormat;
  final Function(Pay updatedPayment) onSave;
  final VoidCallback? onReceiptUpdated;
  final bool isSaving;

  const PaymentEditFormWidget({
    super.key,
    required this.payment,
    required this.dateFormat,
    required this.onSave,
    this.onReceiptUpdated,
    required this.isSaving,
  });

  @override
  State<PaymentEditFormWidget> createState() => _PaymentEditFormWidgetState();
}

class _PaymentEditFormWidgetState extends State<PaymentEditFormWidget> {
  // Controladores para los campos editables
  late final TextEditingController _montoController;
  late final TextEditingController _fechaController;
  String? _comprobanteFileName;
  bool _isUploadingFile = false;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController(
      text: widget.payment.amount.toStringAsFixed(2),
    );
    _fechaController = TextEditingController(
      text: widget.dateFormat.format(DateTime.parse(widget.payment.date)),
    );
    _comprobanteFileName = widget.payment.fileName;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner de estado
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Estado de la Cuota',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatusBanner(tokens),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Sección Fecha y hora
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha y horario',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFormField(
                label: 'Monto *',
                controller: _montoController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildDateField(
                label: 'Fecha del pago *',
                controller: _fechaController,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Sección Comprobante
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.card1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Comprobante de pago',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFileField(tokens),
              const SizedBox(height: 8),
              Text(
                '* El comprobante será revisado por un administrador para validar el pago',
                style: TextStyle(color: tokens.gray, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: _isUploadingFile ? null : _handleUpdateReceipt,
                    icon: _isUploadingFile
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.autorenew_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isUploadingFile ? 'Subiendo...' : 'Modificar',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.tokens.secondaryButton,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Button modificar pago
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: widget.isSaving
                ? null
                : () {
                    // Crea el updatedPayment y llama al callback
                    final updatedPayment = widget.payment.copyWith(
                      amount:
                          double.tryParse(_montoController.text) ??
                          widget.payment.amount,
                      date: _fechaController.text.isNotEmpty
                          ? _fechaController.text
                          : widget.payment.date,
                    );
                    widget.onSave(updatedPayment);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Modificar pago',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────
  // Widgets privados (ahora en este form widget)
  // ────────────────────────────────────────────────

  Widget _buildStatusBanner(AppTokens tokens) {
    // Asumiendo que widget.payment.status es 'Pendiente', 'Aprobado', 'Rechazado', 'Vencida' etc.
    // Ajusta la lógica basada en tu Payment entity (usa widget.payment para datos dinámicos)
    final status = widget.payment.status; // O usa un enum para estado cuota
    Color bannerColor;
    String title;
    String subtitle;
    String description;
    IconData icon;

    // Lógica para cambiar basado en estado (expande según necesites)
    switch (status) {
      case PayState.validated:
        bannerColor = tokens.green;
        title = 'Pago Aprobado';
        subtitle =
            'Último pago: ${widget.dateFormat.format(widget.payment.paymentDate)}';
        description = 'El pago ha sido validado exitosamente';
        icon = Icons.check_circle_outline;
        break;

      case PayState.pending:
        bannerColor = tokens.pending;
        title = 'Pago Pendiente';
        subtitle =
            'Enviado: ${widget.dateFormat.format(widget.payment.sentDate)}';
        description = 'El pago está en revisión';
        icon = Icons.hourglass_empty;
        break;

      case PayState.rejected:
        bannerColor = tokens.redToRosita;
        title = 'Pago Rechazado';
        subtitle = widget.payment.notes ?? 'Ver detalles';
        description = 'El pago no fue aprobado';
        icon = Icons.error_outline;
        break;
    }
    //TODO review this code
    // if (status == PayState.aprobado) {
    //   bannerColor = tokens.green;
    //   title = 'Cuota al día / Pago Aprobado';
    //   subtitle =
    //       'Último pago: ${widget.dateFormat.format(widget.payment.paymentDate)}';
    //   description =
    //       'La cuota está pagada/ El pago ha sido validado exitosamente';
    //   icon = Icons.check_circle_outline;
    // } else if (status == PayState.pendiente) {
    //   bannerColor = tokens.pending ?? Colors.orange;
    //   title = 'Cuota pendiente/ Pago Pendiente';
    //   subtitle = 'Esperando validación';
    //   description = 'La cuota está en revisión / El pago está en revisión';
    //   icon = Icons.hourglass_empty;
    // }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1), // Fondo suave
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: bannerColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: bannerColor, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Campo genérico para monto u otros
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.tokens.stroke),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // Campo para fecha con icono
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.tokens.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            // Mostrar DatePicker
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: widget.dateFormat.parse(controller.text),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              controller.text = widget.dateFormat.format(selectedDate);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.tokens.stroke),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: context.tokens.gray,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Campo para comprobante (simulado, agrega file_picker para upload real)
  Widget _buildFileField(AppTokens tokens) {
    final hasFile =
        _comprobanteFileName != null && _comprobanteFileName!.isNotEmpty;

    return InkWell(
      onTap: hasFile ? _handleDownloadReceipt : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.stroke),
          borderRadius: BorderRadius.circular(8),
          color: tokens.background,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _comprobanteFileName ?? 'Sin comprobante',
                style: TextStyle(
                  color: hasFile ? tokens.redToRosita : tokens.placeholder,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.file_download_outlined,
              color: hasFile ? tokens.text : tokens.gray,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDownloadReceipt() async {
    if (_comprobanteFileName == null || _comprobanteFileName!.isEmpty) return;

    try {
      await FileUploadService.downloadPaymentReceiptWithNotification(
        paymentId: widget.payment.id,
        fileName: _comprobanteFileName!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Comprobante descargado exitosamente'),
            backgroundColor: context.tokens.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateReceipt() async {
    try {
      setState(() => _isUploadingFile = true);

      final option = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.tokens.card1,
          title: Text(
            'Seleccionar comprobante',
            style: TextStyle(color: context.tokens.text),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: context.tokens.text),
                title: Text(
                  'Galería',
                  style: TextStyle(color: context.tokens.text),
                ),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              ListTile(
                leading: Icon(
                  Icons.insert_drive_file,
                  color: context.tokens.text,
                ),
                title: Text(
                  'Archivo',
                  style: TextStyle(color: context.tokens.text),
                ),
                onTap: () => Navigator.of(context).pop('file'),
              ),
            ],
          ),
        ),
      );

      if (option == null) {
        setState(() => _isUploadingFile = false);
        return;
      }

      Map<String, String>? result;

      if (option == 'gallery') {
        final file = await FileUploadService.pickImage(
          source: ImageSource.gallery,
        );
        if (file != null) {
          if (!_isAllowedReceiptExtension(file.path)) {
            if (mounted) {
              setState(() => _isUploadingFile = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Formato no permitido. Usá PNG, JPEG o PDF. JPG se convierte a JPEG.',
                  ),
                  backgroundColor: context.tokens.redToRosita,
                ),
              );
            }
            return;
          }
          result = {
            'fileName': file.path.split('/').last,
            'fileUrl': file.path,
          };
        }
      } else if (option == 'file') {
        final file = await FileUploadService.pickFile(
          allowedExtensions: ['pdf', 'jpeg', 'jpg', 'png'],
        );
        if (file != null) {
          if (!_isAllowedReceiptExtension(file.path)) {
            if (mounted) {
              setState(() => _isUploadingFile = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Formato no permitido. Usá PNG, JPEG o PDF. JPG se convierte a JPEG.',
                  ),
                  backgroundColor: context.tokens.redToRosita,
                ),
              );
            }
            return;
          }
          result = {
            'fileName': file.path.split('/').last,
            'fileUrl': file.path,
          };
        }
      }

      if (result != null && mounted) {
        // Subir el archivo al servidor usando updatePaymentReceipt
        try {
          final uploadResult = await FileUploadService.updatePaymentReceipt(
            paymentId: widget.payment.id,
            file: File(result['fileUrl']!),
          );

          if (mounted) {
            setState(() {
              _comprobanteFileName = uploadResult['fileName'];
              _isUploadingFile = false;
            });

            widget.onReceiptUpdated?.call();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Comprobante actualizado exitosamente'),
                backgroundColor: context.tokens.green,
              ),
            );
          }
        } catch (e) {
          print('❌ Error al subir archivo: $e');
          if (mounted) {
            setState(() => _isUploadingFile = false);

            // Mensaje específico si es error 500 del servidor
            String errorMsg = 'Error al subir archivo';
            if (e.toString().contains('500') ||
                e.toString().contains('Internal Server Error')) {
              errorMsg =
                  'Error del servidor al procesar el archivo. Por favor, intenta más tarde o contacta al administrador.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: context.tokens.redToRosita,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        setState(() => _isUploadingFile = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingFile = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: context.tokens.redToRosita,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  bool _isAllowedReceiptExtension(String path) {
    final parts = path.toLowerCase().split('.');
    if (parts.length < 2) return false;
    final extension = parts.last;
    return extension == 'png' ||
        extension == 'jpeg' ||
        extension == 'jpg' ||
        extension == 'pdf';
  }

  @override
  void dispose() {
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}
