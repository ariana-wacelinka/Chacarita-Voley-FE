import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';

class PaymentHistoryContent extends StatefulWidget {
  final List<Pay> payments;
  final String userName;
  final String userId;

  const PaymentHistoryContent({
    super.key,
    required this.payments,
    required this.userName,
    required this.userId,
  });

  @override
  State<PaymentHistoryContent> createState() => _PaymentHistoryContentState();
}

class _PaymentHistoryContentState extends State<PaymentHistoryContent> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Pay> _filteredPayments = [];
  int _currentPage = 0;
  static const int _itemsPerPage = 7;
  bool _localeInitialized = false;

  late DateFormat _dateFormat;
  late DateFormat _pickerFormat;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _filteredPayments = List.from(widget.payments);
    _updateDisplayedPayments();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('es');
    setState(() {
      _dateFormat = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es');
      _pickerFormat = DateFormat('dd/MM/yyyy');
      _localeInitialized = true;
    });
  }

  @override
  void didUpdateWidget(PaymentHistoryContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payments != widget.payments) {
      _filterPayments();
    }
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
    // Lógica de paginación
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

  List<Pay> get _displayedPayments {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _filteredPayments.length);
    return _filteredPayments.sublist(start, end);
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
          ..._displayedPayments.map(
            (payment) => _buildPaymentItem(payment, tokens),
          ),
          if (_filteredPayments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPagination(tokens),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner(AppTokens tokens) {
    final lastPayment = widget.payments.isNotEmpty
        ? widget.payments.reduce(
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
                    _filterPayments();
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
                    _filterPayments();
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
        ],
      ),
    );
  }

  Widget _buildPagination(AppTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0 ? _previousPage : null,
          icon: Icon(
            Symbols.chevron_left,
            color: _currentPage > 0 ? tokens.text : tokens.placeholder,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$_startItem-$_endItem de ${_filteredPayments.length}',
          style: TextStyle(
            color: tokens.text,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed:
              (_currentPage + 1) * _itemsPerPage < _filteredPayments.length
              ? _nextPage
              : null,
          icon: Icon(
            Symbols.chevron_right,
            color: (_currentPage + 1) * _itemsPerPage < _filteredPayments.length
                ? tokens.text
                : tokens.placeholder,
            size: 20,
          ),
        ),
      ],
    );
  }
}
