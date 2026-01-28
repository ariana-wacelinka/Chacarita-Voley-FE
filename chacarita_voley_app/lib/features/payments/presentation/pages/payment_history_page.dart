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
        time: '10:00:00.000',
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
        time: '10:00:00.000',
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
        time: '10:00:00.000',
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
        time: '10:00:00.000',
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
        time: '10:00:00.000',
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
        time: '10:00:00.000',
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
        time: '10:00:00.000',
        fileName: 'comprobante_may1.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_may1.pdf',
        userName: widget.userName,
        dni: '12345678',
      ),
    ];
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
          : RefreshIndicator(
              onRefresh: _loadPays,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PaymentHistoryContent(
                  payments: _payments,
                  userName: widget.userName,
                  userId: widget.userId,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/payments/create?userId=${widget.userId}');
        },
        backgroundColor: tokens.redToRosita,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
    );
  }
}
