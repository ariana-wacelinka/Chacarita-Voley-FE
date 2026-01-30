import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../data/repositories/pay_repository.dart';
import '../../domain/entities/pay_state.dart';
import '../widgets/payment_history_content_widget.dart';

class PaymentHistoryPage extends StatefulWidget {
  final String userId;
  final String userName;

  const PaymentHistoryPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late final PayRepository _payRepository;
  List<Pay> _payments = [];
  bool _isLoading = true;

  int _currentPage = 0;
  static const int _itemsPerPage = 7;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _payRepository = PayRepository();
    _loadPays();
  }

  Future<void> _loadPays() async {
    setState(() => _isLoading = true);

    try {
      final pays = _payRepository.getPaymentByUserId(widget.userId);
      if (!mounted) return;

      setState(() {
        _payments = pays.isNotEmpty ? pays : _getDummyPayments();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _payments = _getDummyPayments();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error al cargar historial de pagos'),
          backgroundColor: context.tokens.redToRosita,
        ),
      );
    }
  }

  // Datos dummy para visualización (hardcodeados, ordenados por fecha descendente)
  List<Pay> _getDummyPayments() {
    return [
      Pay(
        id: '1',
        status: PayState.validated,
        amount: 20000.0,
        date: '2025-11-09',
        createdAt: '2025-11-09T10:00:00.000',
        fileName: 'comprobante_nov9.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_nov9.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
      Pay(
        id: '2',
        status: PayState.validated,
        amount: 20000.0,
        date: '2025-10-15',
        createdAt: '2025-10-15T10:00:00.000',
        fileName: 'comprobante_oct15.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_oct15.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
      Pay(
        id: '3',
        status: PayState.rejected,
        amount: 20000.0,
        date: '2025-09-20',
        createdAt: '2025-09-20T10:00:00.000',
        fileName: 'comprobante_sep20.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_sep20.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
      Pay(
        id: '4',
        status: PayState.pending,
        amount: 20000.0,
        date: '2025-08-05',
        createdAt: '2025-08-05T10:00:00.000',
        fileName: 'comprobante_aug5.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_aug5.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
      Pay(
        id: '5',
        status: PayState.validated,
        amount: 20000.0,
        date: '2025-07-12',
        createdAt: '2025-07-12T10:00:00.000',
        fileName: 'comprobante_jul12.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_jul12.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
      Pay(
        id: '6',
        status: PayState.validated,
        amount: 20000.0,
        date: '2025-06-25',
        createdAt: '2025-06-25T10:00:00.000',
        fileName: 'comprobante_jun25.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_jun25.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
      Pay(
        id: '7',
        status: PayState.validated,
        amount: 20000.0,
        date: '2025-05-01',
        createdAt: '2025-05-01T10:00:00.000',
        fileName: 'comprobante_may1.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_may1.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
    ];
  }

  List<Pay> get _filteredPayments {
    return _payments.where((payment) {
      bool afterStart =
          _startDate == null ||
          payment.paymentDate.isAfter(
            _startDate!.subtract(const Duration(days: 1)),
          );
      bool beforeEnd =
          _endDate == null ||
          payment.paymentDate.isBefore(_endDate!.add(const Duration(days: 1)));
      return afterStart && beforeEnd;
    }).toList();
  }

  List<Pay> get _displayedPayments {
    final filtered = _filteredPayments;
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
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

  void _onFiltersChanged(DateTime? startDate, DateTime? endDate) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.card1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back, color: tokens.text),
          onPressed: () => context.go('/users/${widget.userId}/view'),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Historial de Pagos',
              style: TextStyle(
                color: tokens.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.userName,
              style: TextStyle(
                color: tokens.placeholder,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(tokens.redToRosita),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadPays,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: PaymentHistoryContent(
                        payments: _displayedPayments,
                        allPayments: _payments,
                        userName: widget.userName,
                        userId: widget.userId,
                        onFiltersChanged: _onFiltersChanged,
                      ),
                    ),
                  ),
                ),
                if (_filteredPayments.isNotEmpty) _buildPagination(tokens),
              ],
            ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            context.push(
              '/payments/create?userId=${widget.userId}&userName=${Uri.encodeComponent(widget.userName)}',
            );
          },
          backgroundColor: context.tokens.redToRosita,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: const [
              Icon(Symbols.credit_card, color: Colors.white, size: 26),
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Symbols.add, color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(AppTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: tokens.card1,
        border: Border(top: BorderSide(color: tokens.stroke)),
      ),
      child: Row(
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
              color:
                  (_currentPage + 1) * _itemsPerPage < _filteredPayments.length
                  ? tokens.text
                  : tokens.placeholder,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
