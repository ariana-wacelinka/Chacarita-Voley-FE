import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';

import '../../../users/domain/entities/user.dart';
import '../../domain/entities/pay.dart';
import '../../domain/entities/pay_state.dart';

//TODO atencion a los deprecated de esta pagina

class CreatePaymentForUserForm extends StatefulWidget {
  final User user; // Usuario pre-seleccionado
  final Function(Pay newPayment) onSave;
  final bool isSaving;

  const CreatePaymentForUserForm({
    super.key,
    required this.user,
    required this.onSave,
    required this.isSaving,
  });

  @override
  State<CreatePaymentForUserForm> createState() =>
      _CreatePaymentForUserFormState();
}

class _CreatePaymentForUserFormState extends State<CreatePaymentForUserForm> {
  // Controladores
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  String? _comprobanteFileName; // Para upload simulado
  PayState _selectedStatus = PayState.pending; // Default

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Pre-cargar dummies para visualización (puedes remover en prod)
    _montoController.text = '20000'; // Dummy monto
    _fechaController.text = _dateFormat.format(
      DateTime.now(),
    ); // Dummy fecha actual
    _comprobanteFileName = null; // Inicia sin file
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner Estado de la Cuota (basado en user.estadoCuota)
        _buildStatusBanner(tokens),

        const SizedBox(height: 24),

        // Sección Fecha y Monto
        Text(
          'Fecha y Monto',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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

        const SizedBox(height: 24),

        // Sección Comprobante
        Text(
          'Comprobante de pago',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildFileUploadField(tokens),
        const SizedBox(height: 4),
        Text(
          '* El comprobante será revisado por un administrador para validar el pago',
          style: TextStyle(color: tokens.gray, fontSize: 12),
        ),

        const SizedBox(height: 24),

        // Sección Estado del pago
        Text(
          'Estado del pago',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatusRadioGroup(tokens),

        const SizedBox(height: 32),

        // Botón Registrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isSaving
                ? null
                : () {
                    if (_montoController.text.isEmpty ||
                        _fechaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Completa los campos requeridos'),
                        ),
                      );
                      return;
                    }
                    final newPayment = Pay(
                      userId: widget.user.id!,
                      userName: widget.user.nombreCompleto,
                      dni: widget.user.dni,
                      paymentDate: _dateFormat.parse(_fechaController.text),
                      sentDate: DateTime.now(),
                      amount: double.parse(_montoController.text),
                      status: _selectedStatus,
                      comprobantePath: _comprobanteFileName,
                    );
                    widget.onSave(newPayment);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.redToRosita,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: widget.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Registrar pago',
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

  // Banner Estado de la Cuota (dinámico basado en widget.user.estadoCuota)
  Widget _buildStatusBanner(AppTokens tokens) {
    Color bannerColor = tokens.redToRosita;
    String title = 'Cuota vencida';
    String subtitle = 'Último pago: 15/04';
    String description = 'La cuota mensual está vencida';
    IconData icon = Icons.error_outline;

    switch (widget.user.estadoCuota) {
      case EstadoCuota.alDia:
        bannerColor = tokens.green;
        title = 'Cuota al día';
        subtitle = 'Último pago: [fecha dummy]';
        description = 'La cuota está pagada';
        icon = Icons.check_circle_outline;
        break;
      case EstadoCuota.ultimoPago:
        bannerColor = tokens.pending ?? Colors.orange;
        title = 'Último pago';
        subtitle = 'Último pago: [fecha dummy]';
        description = 'Próximo vencimiento pronto';
        icon = Icons.hourglass_empty;
        break;
      case EstadoCuota.vencida:
        // Default ya set
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bannerColor.withOpacity(0.3)),
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
                    fontSize: 16,
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
                  style: TextStyle(color: bannerColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Campo genérico para monto
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

  // Campo para fecha
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
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              controller.text = _dateFormat.format(selectedDate);
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

  // Campo para comprobante
  Widget _buildFileUploadField(AppTokens tokens) {
    return GestureDetector(
      onTap: () {
        // Simular upload (en prod, usa file_picker)
        setState(() {
          _comprobanteFileName =
              'comprobante_${DateTime.now().millisecondsSinceEpoch}.pdf';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.stroke),
          borderRadius: BorderRadius.circular(8),
          color: tokens.permanentWhite,
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: tokens.redToRosita,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _comprobanteFileName ??
                  'Arrastrá y soltá el comprobante acá o seleccioná un archivo',
              style: TextStyle(
                color: _comprobanteFileName != null
                    ? tokens.text
                    : tokens.redToRosita,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Radios para estado
  Widget _buildStatusRadioGroup(AppTokens tokens) {
    return Column(
      children: PayState.values.map((status) {
        return RadioListTile<PayState>(
          title: Text(status.name.capitalize()),
          subtitle: Text(status.displayName),
          value: status,
          groupValue: _selectedStatus,
          onChanged: (value) {
            setState(() => _selectedStatus = value!);
          },
          activeColor: tokens.redToRosita,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}

// Extensión para capitalize (opcional, si no la tienes ya)
extension StringCapitalize on String {
  String capitalize() =>
      "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
