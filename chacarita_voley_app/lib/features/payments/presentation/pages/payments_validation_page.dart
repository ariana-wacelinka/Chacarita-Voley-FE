import 'package:chacarita_voley_app/features/payments/data/repositories/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/payment.dart';
import '../widgets/payment_list_widget.dart';

class PaymentsValidationPage extends StatefulWidget {
  const PaymentsValidationPage({super.key});

  @override
  State<PaymentsValidationPage> createState() => _PaymentsValidationPageState();
}

class _PaymentsValidationPageState extends State<PaymentsValidationPage> {
  // Data dummy (replace with real data later)
  late final List<Payment> initialPayments = [
    Payment(
      userName: 'Marcos Paz',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20000.00,
      status: PaymentStatus.pendiente,
    ),
    Payment(
      userName: 'Enrique Cruz',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20.00,
      status: PaymentStatus.aprobado,
    ),
    Payment(
      userName: 'Mari Gonzales',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20.00,
      status: PaymentStatus.rechazado,
    ),
  ];

  //USe the repository for dummy
  late final PaymentRepository _repository;
  late List<Payment> _payments;
  bool _isLoading = true;

  void initState() {
    super.initState();
    _repository = PaymentRepository();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final payments = _repository.getPayments();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al cargar pagos')));
      }
    }
  }

  // Filter
  // String _dniFilter = '';
  // DateTime? _startDate;
  // DateTime? _endDate;
  // TimeOfDay? _startTime;
  // TimeOfDay? _endTime;
  // final Set<String> _selectedFilters = {};

  // Format
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Column(
          children: [
            // Resumen
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
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
                        Icon(
                          Icons.check_circle_outline,
                          color: tokens.gray,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Resumen de Validaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: tokens.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          '70',
                          'Aprobados',
                          tokens.green,
                          tokens.gray,
                        ),
                        _buildSummaryItem(
                          '30',
                          'Rechazados',
                          tokens.redToRosita,
                          tokens.gray,
                        ),
                        _buildSummaryItem(
                          '70',
                          'Pendientes',
                          tokens.pending,
                          tokens.gray,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                        Icon(
                          Icons.filter_alt_outlined,
                          color: tokens.gray,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtro',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: tokens.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fechas (ejemplo estático por ahora)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            'Fecha de inicio *',
                            DateTime.now(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            'Fecha de fin *',
                            DateTime.now().add(const Duration(days: 30)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            'Hora de inicio *',
                            TimeOfDay.now(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeField(
                            'Hora de fin *',
                            TimeOfDay.now(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Filtrar por:',
                      style: TextStyle(fontSize: 14, color: tokens.gray),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildFilterButton('Validados', tokens.green),
                        const SizedBox(width: 8),
                        _buildFilterButton('Rechazados', tokens.redToRosita),
                        const SizedBox(width: 8),
                        _buildFilterButton('Pendientes', tokens.pending),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              // Inifity scroll label payment
              child: PaymentListWidget(initialPayments: _payments),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Widget private
  // ────────────────────────────────────────────────

  Widget _buildSummaryItem(
    String number,
    String label,
    Color numberColor,
    Color labelColor,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: numberColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: labelColor)),
      ],
    );
  }

  // Widget for date field
  Widget _buildDateField(String label, DateTime date) {
    final tokens = context.tokens;
    final hasAsterisk = label.endsWith(' *');
    final textPart = hasAsterisk
        ? label.substring(0, label.length - 2).trim()
        : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(textPart, style: TextStyle(fontSize: 14, color: tokens.text)),
            if (hasAsterisk)
              Text(
                ' *',
                style: TextStyle(fontSize: 14, color: tokens.redToRosita),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: tokens.stroke),
            borderRadius: BorderRadius.circular(8),
            color: tokens.permanentWhite,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dateFormat.format(date),
                style: TextStyle(color: tokens.text),
              ),
              Icon(Icons.calendar_today_outlined, color: tokens.gray),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time) {
    final tokens = context.tokens;
    final hasAsterisk = label.endsWith(' *');
    final textPart = hasAsterisk
        ? label.substring(0, label.length - 2).trim()
        : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(textPart, style: TextStyle(fontSize: 14, color: tokens.text)),
            if (hasAsterisk)
              Text(
                ' *',
                style: TextStyle(fontSize: 14, color: tokens.redToRosita),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: tokens.stroke),
            borderRadius: BorderRadius.circular(8),
            color: tokens.permanentWhite,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: tokens.text),
              ),
              Icon(Icons.access_time_outlined, color: tokens.gray),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String label, Color color) {
    // Por ahora sin estado seleccionado (puedes agregar lógica después)
    return GFButton(
      onPressed: () {
        // Implementar toggle cuando lo necesites
      },
      text: label,
      shape: GFButtonShape.standard,

      type: GFButtonType.outline,
      color: color,
      textStyle: TextStyle(color: context.tokens.text),
    );
  }
}
