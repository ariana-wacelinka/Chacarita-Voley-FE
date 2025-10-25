import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/payment.dart';
import '../../domain/entities/payment_list_widget.dart';

class PaymentsValidationPage extends StatefulWidget {
  const PaymentsValidationPage({super.key});

  @override
  State<PaymentsValidationPage> createState() => _PaymentsValidationPageState();
}

class _PaymentsValidationPageState extends State<PaymentsValidationPage> {
  // Data dummy (replace with API/DB)
  late final List<Payment> initialPayments = [
    Payment(
      userName: 'Juan Perez',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20000.00,
      status: 'Pendiente',
    ),
    Payment(
      userName: 'Enrique Cruz',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20.00,
      status: 'Aprobado',
    ),
    Payment(
      userName: 'Mari Gonzales',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20.00,
      status: 'Rechazado',
    ),
  ];

  // Filter (DateTime, TimeOfDay)
  String _dniFilter = '';
  DateTime? _dateFilter;
  TimeOfDay? _timeFilter;

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<String> _selectedFilters =
      {}; // For multiple filter selection (Validated, etc)

  // Formatt
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    // Filtered Payments
    final filteredPayments = initialPayments.where((p) {
      bool matchesDni = _dniFilter.isEmpty || p.dni.contains(_dniFilter);
      bool matchesDate = _dateFilter == null || p.sentDate.day == _dateFilter;
      bool matchesTime =
          _timeFilter == null || p.paymentDate.hour == _timeFilter;
      return matchesDni && matchesDate && matchesTime;
    }).toList();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: tokens.background,
            // Background white
            border: Border.all(color: tokens.strokeToNoStroke.withOpacity(0.5)),
            // Gray light border
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: tokens.gray,
                    size: 24.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Resumen de Validaciones',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: tokens.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    number: '70',
                    label: 'Aprobados',
                    numberColor: tokens.green,
                    labelColor: tokens.gray,
                  ),
                  _buildSummaryItem(
                    number: '30',
                    label: 'Rechazados',
                    numberColor: tokens.redToRosita,
                    labelColor: tokens.gray,
                  ),
                  _buildSummaryItem(
                    number: '70',
                    label: 'Pendientes',
                    numberColor: tokens.pending,
                    labelColor: tokens.gray,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            color: tokens.strokeToNoStroke.withOpacity(0.5),
            thickness: 1.0,
            height: 1.0,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: tokens.background,
            border: Border.all(color: tokens.strokeToNoStroke.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined, // Icon Funnel
                    color: tokens.gray,
                    size: 24.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Filtro',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: tokens.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'Fecha de inicio *',
                      date: _startDate,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildDateField(
                      label: 'Fecha de fin *',
                      date: _endDate,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeField(
                      label: 'Hora de inicio *',
                      time: _startTime,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) setState(() => _startTime = time);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildTimeField(
                      label: 'Hora de fin *',
                      time: _endTime,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (time != null) setState(() => _endTime = time);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              // Button Filter
              Text(
                'Filtrar por:',
                style: TextStyle(fontSize: 14.0, color: tokens.gray),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterButton('Validados', tokens.green),
                  const SizedBox(width: 8.0),
                  _buildFilterButton('Rechazados', tokens.redToRosita),
                  const SizedBox(width: 8.0),
                  _buildFilterButton('Pendientes', tokens.pending),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          // Inifity scroll label payment
          child: PaymentListWidget(initialPayments: initialPayments),
        ),

        // Pagination (simple,"1-7 de 87")
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GFIconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {}, // Lógica página anterior
                type: GFButtonType.transparent,
              ),
              Text('1-7 de 87', style: TextStyle(color: tokens.text)),
              GFIconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {}, // logic to next page
                type: GFButtonType.transparent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String number,
    required String label,
    required Color numberColor,
    required Color labelColor,
  }) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: numberColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14.0, color: labelColor)),
      ],
    );
  }

  // Widget para campo de fecha
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: tokens.redToRosita, // Asterisco rojo
          ),
        ),
        const SizedBox(height: 4.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: tokens.stroke),
              borderRadius: BorderRadius.circular(8.0),
              color: tokens.permanentWhite,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _dateFormat.format(date) : 'DD/MM/AAAA',
                  style: TextStyle(
                    color: date != null ? tokens.text : tokens.placeholder,
                  ),
                ),
                Icon(Icons.calendar_today_outlined, color: tokens.gray),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget para campo de hora
  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            color: tokens.redToRosita, // Asterisco rojo
          ),
        ),
        const SizedBox(height: 4.0),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: tokens.stroke),
              borderRadius: BorderRadius.circular(8.0),
              color: tokens.permanentWhite,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null
                      ? _timeFormat.format(
                          DateTime(0, 0, 0, time.hour, time.minute),
                        )
                      : 'HH:MM',
                  style: TextStyle(
                    color: time != null ? tokens.text : tokens.placeholder,
                  ),
                ),
                Icon(Icons.access_time_outlined, color: tokens.gray),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Botón de filtro (usando GFButton para estilo)
  Widget _buildFilterButton(String label, Color color) {
    final isSelected = _selectedFilters.contains(label);
    return GFButton(
      onPressed: () {
        setState(() {
          if (isSelected) {
            _selectedFilters.remove(label);
          } else {
            _selectedFilters.add(label);
          }
        });
      },
      text: label,
      shape: GFButtonShape.pills,
      type: isSelected ? GFButtonType.solid : GFButtonType.outline,
      color: isSelected ? color : context.tokens.stroke,
      borderSide: BorderSide(color: context.tokens.stroke),
      textStyle: TextStyle(
        color: isSelected ? context.tokens.permanentWhite : context.tokens.text,
      ),
    );
  }
}

// Widget reutilizable para cada card de validación de pago (usando GFCard, GFListTile, GFBadge, GFButton)
class PaymentValidationCard extends StatelessWidget {
  final Payment payment;

  const PaymentValidationCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Color statusColor;
    GFButtonType buttonType;
    switch (payment.status) {
      case 'Pendiente':
        statusColor = tokens.pending;
        buttonType = GFButtonType.outline;
        break;
      case 'Vencida':
        statusColor = tokens.redToRosita;
        buttonType = GFButtonType.solid;
        break;
      default:
        statusColor = tokens.green;
        buttonType = GFButtonType.transparent;
    }

    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      boxFit: BoxFit.cover,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      content: GFListTile(
        title: Text(
          payment.userName,
          style: TextStyle(fontWeight: FontWeight.bold, color: tokens.text),
        ),
        subTitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: ${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
            ),
            Text(
              'Hora: ${payment.paymentDate.hour}:${payment.paymentDate.minute}',
            ),
            Text('Monto: \$${payment.amount.toStringAsFixed(2)}'),
          ],
        ),
        description: GFBadge(
          text: payment.status,
          color: statusColor,
          shape: GFBadgeShape.pills,
        ),
        icon: GFButton(
          onPressed: () {
            // Lógica para validar (navega a detalle o modal)
          },
          text: 'Validar',
          color: tokens.redToRosita,
          shape: GFButtonShape.standard,
          type: buttonType,
        ),
      ),
    );
  }
}
