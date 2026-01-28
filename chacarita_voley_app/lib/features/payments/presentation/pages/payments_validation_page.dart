import 'dart:core';

import 'package:chacarita_voley_app/features/payments/data/repositories/pay_repository.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';

class PaymentsValidationPage extends StatefulWidget {
  const PaymentsValidationPage({super.key});

  @override
  State<PaymentsValidationPage> createState() => _PaymentsValidationPageState();
}

class _PaymentsValidationPageState extends State<PaymentsValidationPage> {
  late final PayRepository _repository;
  late List<Pay> _pays;
  bool _isLoading = true;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  PayState? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  @override
  void initState() {
    super.initState();
    _repository = PayRepository();
    _loadPays();
  }

  Future<void> _loadPays() async {
    setState(() => _isLoading = true);
    try {
      final payments = _repository.getPayments();
      setState(() {
        _pays = payments;
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

  int get _approvedCount =>
      _pays.where((p) => p.status == PayState.validated).length;
  int get _rejectedCount =>
      _pays.where((p) => p.status == PayState.rejected).length;
  int get _pendingCount =>
      _pays.where((p) => p.status == PayState.pending).length;

  List<Pay> get _filteredPays {
    if (_selectedStatus == null) return _pays;
    return _pays.where((p) => p.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: tokens.background,
        body: Center(
          child: CircularProgressIndicator(color: tokens.redToRosita),
        ),
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: _filteredPays.isEmpty
            ? _buildEmptyState(context)
            : _buildPaymentsList(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummarySection(context)),
        SliverToBoxAdapter(child: _buildFilterSection(context)),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.payments,
                  size: 64,
                  color: context.tokens.placeholder,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay pagos para validar',
                  style: TextStyle(
                    color: context.tokens.placeholder,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPays.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSummarySection(context),
          );
        }

        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFilterSection(context),
          );
        }

        final paymentIndex = index - 2;
        final payment = _filteredPays[paymentIndex];
        return _buildPaymentCard(context, payment);
      },
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.check_circle_outline,
                color: context.tokens.gray,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de Validaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                number: _approvedCount.toString(),
                label: 'Aprobados',
                numberColor: context.tokens.green,
              ),
              _buildSummaryItem(
                number: _rejectedCount.toString(),
                label: 'Rechazados',
                numberColor: context.tokens.redToRosita,
              ),
              _buildSummaryItem(
                number: _pendingCount.toString(),
                label: 'Pendientes',
                numberColor: context.tokens.pending,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String number,
    required String label,
    required Color numberColor,
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
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.tokens.placeholder),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.filter_alt,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.tokens.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Fecha de inicio',
                  value: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  label: 'Fecha de fin',
                  value: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'Hora de inicio',
                  value: _startTime,
                  onTap: () => _selectTime(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  label: 'Hora de fin',
                  value: _endTime,
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Filtrar por:',
            style: TextStyle(
              color: context.tokens.text,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'Validados',
                status: PayState.validated,
                color: context.tokens.green,
              ),
              _buildFilterChip(
                label: 'Rechazados',
                status: PayState.rejected,
                color: context.tokens.redToRosita,
              ),
              _buildFilterChip(
                label: 'Pendientes',
                status: PayState.pending,
                color: context.tokens.pending,
              ),
            ],
          ),
          if (_selectedStatus != null ||
              _startDate != null ||
              _endDate != null ||
              _startTime != null ||
              _endTime != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _startDate = null;
                  _endDate = null;
                  _startTime = null;
                  _endTime = null;
                });
              },
              icon: Icon(Symbols.close, size: 16, color: context.tokens.text),
              label: Text(
                'Limpiar filtros',
                style: TextStyle(color: context.tokens.text),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required PayState status,
    required Color color,
  }) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : context.tokens.stroke,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : context.tokens.text,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Pay payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tokens.stroke),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nombre, Badge y Acciones
            Row(
              children: [
                Expanded(
                  child: Text(
                    payment.userName,
                    style: TextStyle(
                      color: context.tokens.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(payment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(payment.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.tokens.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.tokens.stroke),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          // TODO: Ver detalles del pago
                        },
                        child: Icon(
                          Symbols.visibility,
                          color: context.tokens.placeholder,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          // TODO: Ver comprobante
                        },
                        child: Icon(
                          Symbols.description,
                          color: context.tokens.placeholder,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'DNI: ${payment.dni}',
              style: TextStyle(color: context.tokens.placeholder, fontSize: 12),
            ),
            const SizedBox(height: 16),
            // Fechas
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de Pago',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dateFormat.format(payment.paymentDate),
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enviado',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dateFormat.format(payment.sentDate),
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Monto y botones de validación
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monto',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${payment.amount.toStringAsFixed(3).replaceAll('.', ',')}',
                        style: TextStyle(
                          color: context.tokens.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (payment.status == PayState.pending)
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            _showValidationDialog(context, payment, true);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            color: context.tokens.green,
                            child: Icon(
                              Symbols.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _showValidationDialog(context, payment, false);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            color: context.tokens.redToRosita,
                            child: Icon(
                              Symbols.close,
                              color: Colors.white,
                              size: 20,
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
      ),
    );
  }

  Color _getStatusColor(PayState status) {
    switch (status) {
      case PayState.validated:
        return context.tokens.green;
      case PayState.rejected:
        return context.tokens.redToRosita;
      case PayState.pending:
        return context.tokens.pending;
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: context.tokens.redToRosita,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: context.tokens.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.tokens.stroke),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? _dateFormat.format(value) : 'DD/MM/AAAA',
                    style: TextStyle(
                      color: value != null
                          ? context.tokens.text
                          : context.tokens.placeholder,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Symbols.calendar_month,
                  size: 20,
                  color: context.tokens.placeholder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: context.tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: context.tokens.redToRosita,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: context.tokens.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.tokens.stroke),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                        : 'HH:MM',
                    style: TextStyle(
                      color: value != null
                          ? context.tokens.text
                          : context.tokens.placeholder,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Symbols.schedule,
                  size: 20,
                  color: context.tokens.placeholder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.tokens.redToRosita,
              onPrimary: Colors.white,
              surface: context.tokens.card1,
              onSurface: context.tokens.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.tokens.redToRosita,
              onPrimary: Colors.white,
              surface: context.tokens.card1,
              onSurface: context.tokens.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _showValidationDialog(BuildContext context, Pay payment, bool approve) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.tokens.card1,
        title: Text(
          approve ? '¿Aprobar pago?' : '¿Rechazar pago?',
          style: TextStyle(color: context.tokens.text),
        ),
        content: Text(
          'Esta acción ${approve ? 'aprobará' : 'rechazará'} el pago de ${payment.userName} por \$${payment.amount.toStringAsFixed(3).replaceAll('.', ',')}',
          style: TextStyle(color: context.tokens.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.tokens.placeholder),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar aprobación/rechazo
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(approve ? 'Pago aprobado' : 'Pago rechazado'),
                  backgroundColor: approve
                      ? context.tokens.green
                      : context.tokens.redToRosita,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: approve
                  ? context.tokens.green
                  : context.tokens.redToRosita,
            ),
            child: Text(
              approve ? 'Aprobar' : 'Rechazar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
