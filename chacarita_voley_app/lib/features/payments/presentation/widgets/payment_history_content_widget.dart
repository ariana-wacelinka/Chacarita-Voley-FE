// lib/features/payments/presentation/widgets/payment_history_content.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/payment.dart';

class PaymentHistoryContent extends StatefulWidget {
  final List<Payment> payments;
  final String userName;

  const PaymentHistoryContent({
    super.key,
    required this.payments,
    required this.userName,
  });

  @override
  State<PaymentHistoryContent> createState() => _PaymentHistoryContentState();
}

class _PaymentHistoryContentState extends State<PaymentHistoryContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Payment> _filteredPayments = [];
  int _currentPage = 0;
  static const int _itemsPerPage = 10; // Ajustable

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _pickerFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _filteredPayments = widget.payments;
    _updateDisplayedPayments();
  }

  void _filterPayments() {
    setState(() {
      _currentPage = 0;
      _filteredPayments = widget.payments.where((payment) {
        bool afterStart =
            _startDate == null ||
            payment.paymentDate.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            );
        bool beforeEnd =
            _endDate == null ||
            payment.paymentDate.isBefore(
              _endDate!.add(const Duration(days: 1)),
            );
        return afterStart && beforeEnd;
      }).toList();
      _updateDisplayedPayments();
    });
  }

  void _updateDisplayedPayments() {
    // Lógica de paginación (puedes expandir con InfiniteScroll si necesitas)
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _filteredPayments.length) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  int get _startItem =>
      _filteredPayments.isEmpty ? 0 : _currentPage * _itemsPerPage + 1;

  int get _endItem =>
      ((_currentPage + 1) * _itemsPerPage).clamp(0, _filteredPayments.length);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner de Estado de la Cuota (similar al de edit, pero fijo para vencida en dummy)
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildStatusBanner(tokens),
        ),

        // Sección Filtros
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtros',
                style: TextStyle(
                  color: tokens.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePickerField(
                      label: 'Desde',
                      date: _startDate,
                      onSelected: (date) {
                        setState(() => _startDate = date);
                        _filterPayments();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePickerField(
                      label: 'Hasta',
                      date: _endDate,
                      onSelected: (date) {
                        setState(() => _endDate = date);
                        _filterPayments();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de pagos
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredPayments.length,
          itemBuilder: (context, index) {
            final payment = _filteredPayments[index];
            return _buildPaymentItem(payment, tokens);
          },
        ),

        // Paginación (similar a users_page)
        if (_filteredPayments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _currentPage > 0 ? _previousPage : null,
                  icon: Icon(
                    Symbols.chevron_left,
                    color: _currentPage > 0 ? tokens.text : tokens.gray,
                  ),
                ),
                Text('$_startItem-$_endItem de ${_filteredPayments.length}'),
                IconButton(
                  onPressed:
                      (_currentPage + 1) * _itemsPerPage <
                          _filteredPayments.length
                      ? _nextPage
                      : null,
                  icon: Icon(
                    Symbols.chevron_right,
                    color:
                        (_currentPage + 1) * _itemsPerPage <
                            _filteredPayments.length
                        ? tokens.text
                        : tokens.gray,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Banner de estado (fijo para ejemplo, pero puedes hacerlo dinámico basado en último pago)
  Widget _buildStatusBanner(AppTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.redToRosita.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: tokens.redToRosita, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuota vencida',
                  style: TextStyle(
                    color: tokens.redToRosita,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Último pago: 15/04',
                  style: TextStyle(color: tokens.redToRosita),
                ),
                Text(
                  'La cuota mensual está vencida',
                  style: TextStyle(color: tokens.redToRosita),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Campo date picker
  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        onSelected(selected);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.tokens.text)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: context.tokens.stroke),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _pickerFormat.format(date) : 'DD/MM/AAAA',
                  style: TextStyle(
                    color: date != null
                        ? context.tokens.text
                        : context.tokens.gray,
                  ),
                ),
                Icon(Icons.calendar_today, color: context.tokens.gray),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Item de lista de pago
  Widget _buildPaymentItem(Payment payment, AppTokens tokens) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        _dateFormat.format(payment.paymentDate),
        style: TextStyle(color: tokens.text, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${payment.amount.toStringAsFixed(0)}',
            style: TextStyle(color: tokens.text, fontSize: 16),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.download_outlined, color: tokens.gray),
            onPressed: () {
              // Lógica para descargar comprobante (abrir URL o file)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Descargando ${payment.comprobantePath ?? 'comprobante'}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
