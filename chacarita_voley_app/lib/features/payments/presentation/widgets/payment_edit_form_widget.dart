import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../domain/entities/pay_state.dart';

class PaymentEditFormWidget extends StatefulWidget {
  final Pay payment;
  final DateFormat dateFormat;
  final Function(Pay updatedPayment) onSave;
  final bool isSaving;

  const PaymentEditFormWidget({
    super.key,
    required this.payment,
    required this.dateFormat,
    required this.onSave,
    required this.isSaving,
  });

  @override
  State<PaymentEditFormWidget> createState() => _PaymentEditFormWidgetState();
}

class _PaymentEditFormWidgetState extends State<PaymentEditFormWidget> {
  // Controladores para los campos editables
  late final TextEditingController _montoController;
  late final TextEditingController _fechaController;
  String?
  _comprobanteFileName; // Para el archivo (simulado, puedes usar file_picker para upload real)

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController(
      text: widget.payment.amount.toStringAsFixed(2),
    );
    _fechaController = TextEditingController(
      text: widget.dateFormat.format(widget.payment.paymentDate),
    );
    _comprobanteFileName =
        'Comprobante mayoVoley.pdf'; // Simulado del existente
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
              Text(
                'Comprobante de pago',
                style: TextStyle(
                  color: tokens.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFileField(tokens),
              const SizedBox(height: 4),
              Text(
                '* El comprobante será revisado por un administrador para validar el pago',
                style: TextStyle(color: tokens.gray, fontSize: 12),
              ),
              // Button modificar
              SizedBox(
                // width: (double.infinity / 2).toDouble(),
                width: 250,
                height: 30, // altura típica para botones principales
                child: ElevatedButton.icon(
                  onPressed: () {
                    //TODO
                  },
                  icon: const Icon(
                    Icons.autorenew_rounded,
                    // ↺  (también puedes usar Icons.refresh_rounded)
                    size: 22,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Modificar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.tokens.gray,
                    // tu color rojo/rosado del tema
                    // Si no tienes el token o quieres un color fijo de emergencia:
                    // backgroundColor: Color(0xFFE53935),         // rojo más vivo
                    // backgroundColor: Color(0xFFD32F2F),         // rojo material
                    foregroundColor: Colors.white,
                    elevation: 0,
                    // sin sombra (como en tu captura)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        999,
                      ), // muy redondeado → casi píldora
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
                      paymentDate:
                          widget.dateFormat.tryParse(_fechaController.text) ??
                          widget.payment.paymentDate,
                      // Actualiza status si es necesario, o recalcula basado en fecha
                      // comprobante: si hay nuevo file, actualízalo
                    );
                    widget.onSave(updatedPayment);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.redToRosita,
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
        bannerColor = tokens.pending ?? Colors.orange;
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
    return GestureDetector(
      onTap: () {
        // Lógica para subir archivo (usa package file_picker)
        // Ej: final result = await FilePicker.platform.pickFiles();
        // if (result != null) _comprobanteFileName = result.files.single.name;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.stroke),
          borderRadius: BorderRadius.circular(8),
          color: tokens.permanentWhite,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _comprobanteFileName ?? 'Seleccionar archivo',
                style: TextStyle(
                  color: _comprobanteFileName != null
                      ? tokens.text
                      : tokens.placeholder,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.file_download_outlined, color: tokens.gray),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}
