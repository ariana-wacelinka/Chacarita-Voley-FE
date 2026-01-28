import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../domain/entities/pay_state.dart';

class PaymentHistoryContent extends StatefulWidget {
  final List<Pay> payments;
  final List<Pay> allPayments;
  final String userName;
  final String userId;
  final Function(DateTime?, DateTime?) onFiltersChanged;

  const PaymentHistoryContent({
    super.key,
    required this.payments,
    required this.allPayments,
    required this.userName,
    required this.userId,
    required this.onFiltersChanged,
  });

  @override
  State<PaymentHistoryContent> createState() => _PaymentHistoryContentState();
}

class _PaymentHistoryContentState extends State<PaymentHistoryContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _localeInitialized = false;

  late DateFormat _dateFormat;
  late DateFormat _pickerFormat;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('es');
    setState(() {
      _dateFormat = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es');
      _pickerFormat = DateFormat('dd/MM/yyyy');
      _localeInitialized = true;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_startDate, _endDate);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (!_localeInitialized) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(tokens.redToRosita),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBanner(tokens),
          const SizedBox(height: 24),
          _buildFiltersSection(tokens),
          const SizedBox(height: 24),
          ...widget.payments.map(
            (payment) => _buildPaymentItem(payment, tokens),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(AppTokens tokens) {
    final lastPayment = widget.allPayments.isNotEmpty
        ? widget.allPayments.reduce(
            (a, b) => a.paymentDate.isAfter(b.paymentDate) ? a : b,
          )
        : null;

    final lastPaymentDate = lastPayment != null
        ? DateFormat('dd/MM').format(lastPayment.paymentDate)
        : 'N/A';

    final bannerColor = tokens.redToRosita;
    final title = 'Cuota vencida';
    final subtitle = 'Último pago: $lastPaymentDate';
    final description = 'La cuota mensual está vencida';
    const icon = Symbols.error;

    return Container(
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
              Icon(Symbols.credit_card, color: tokens.text, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estado de la Cuota',
                style: TextStyle(
                  color: tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bannerColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: bannerColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: bannerColor, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(color: bannerColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(icon, color: bannerColor, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(AppTokens tokens) {
    return Container(
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
              Icon(Symbols.filter_alt, color: tokens.text, size: 18),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  color: tokens.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                    _applyFilters();
                  },
                  tokens: tokens,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePickerField(
                  label: 'Hasta',
                  date: _endDate,
                  onSelected: (date) {
                    setState(() => _endDate = date);
                    _applyFilters();
                  },
                  tokens: tokens,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onSelected,
    required AppTokens tokens,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: tokens.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              locale: const Locale('es'),
            );
            onSelected(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: tokens.stroke),
              borderRadius: BorderRadius.circular(8),
              color: tokens.card1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _pickerFormat.format(date) : 'DD/MM/AAAA',
                  style: TextStyle(
                    color: date != null ? tokens.text : tokens.placeholder,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Symbols.calendar_today,
                  color: tokens.placeholder,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(Pay payment, AppTokens tokens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: tokens.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.stroke),
      ),
      child: Row(
        children: [
          Icon(Symbols.calendar_today, color: tokens.placeholder, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _dateFormat.format(payment.paymentDate),
              style: TextStyle(
                color: tokens.text,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '\$${payment.amount.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '')}',
            style: TextStyle(
              color: tokens.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Symbols.download, color: tokens.placeholder, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Descargando ${payment.fileName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          if (payment.status == PayState.validated ||
              payment.status == PayState.rejected) ...[
            const SizedBox(width: 4),
            Container(
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: tokens.stroke, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Modificar pago ${payment.id}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.edit, size: 16, color: tokens.text),
                        const SizedBox(width: 6),
                        Text(
                          'Modificar',
                          style: TextStyle(
                            color: tokens.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
