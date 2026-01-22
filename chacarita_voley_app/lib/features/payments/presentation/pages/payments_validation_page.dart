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
  // Data dummy (replace with API/DB)
  late final List<Payment> initialPayments = [
    Payment(
      userId: '10',
      userName: 'Marcos Paz',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20000.00,
      status: PaymentStatus.pendiente,
    ),
    Payment(
      userId: '11',
      userName: 'Enrique Cruz',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12),
      sentDate: DateTime(2025, 6, 15),
      amount: 20.00,
      status: PaymentStatus.aprobado,
    ),
    Payment(
      userId: '12',
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

  Filter
  String _dniFilter = '';
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<String> _selectedFilters = {};

  // Format
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
                          number: '70',
                          label: 'Aprobados',
                          numberColor: tokens.green,
                          labelColor: tokens.gray,
                        ),
                        _buildSummaryItem(
                          number: '30',
                          label: 'Rechazados',
                          numberColor:tokens.redToRosita,
                          labelColor:tokens.gray,
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
                            label: 'Fecha de inicio *',
                            // DateTime.now(),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            // 'Fecha de fin *',
                            // DateTime.now().add(const Duration(days: 30)),
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
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            // 'Hora de inicio *',
                            // TimeOfDay.now(),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeField(
                            // 'Hora de fin *',
                            // TimeOfDay.now(),
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
                    const SizedBox(height: 16),
                    // Button Filter
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
              child: PaymentListWidget(initialPayments: _payments), //initialPayments TODO
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Widget private
  // ────────────────────────────────────────────────

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
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: numberColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: labelColor)),
      ],
    );
  }

  // Widget para campo de fecha
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap, //TODO que es el VoidCallback
  }) {
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
        GestureDetector(
          onTap: onTap,
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

  Widget _buildTimeField(String label, TimeOfDay time, VoidCallback onTap) {
    final tokens = context.tokens;
    bool hasAsterisk = label.endsWith(' *');
    String textPart = hasAsterisk
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
        GestureDetector(
          onTap: onTap,
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
      // shape: GFButtonShape.standard,
      //
      // type: GFButtonType.outline,
      // color: color,
      // textStyle: TextStyle(color: context.tokens.text),
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
