// lib/features/payments/presentation/pages/payment_history_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../data/repositories/pay_repository.dart'; // Asumiendo que existe o crea uno similar a UserRepository
import '../../domain/entities/pay_state.dart';
import '../widgets/payment_history_content_widget.dart'; // Import del nuevo widget

class PaymentHistoryPage extends StatefulWidget {
  final String userId; // Para cargar pagos del usuario específico
  final String userName; // Para mostrar en el título

  const PaymentHistoryPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  late final PayRepository _payRepository; // Similar a UserRepository
  List<Pay> _pay = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _payRepository = PayRepository();
    _loadPays();
  }

  Future<void> _loadPays() async {
    try {
      // Cargar pagos reales del repo por userId
      final pays = _payRepository.getPaymentByUserId(widget.userId);
      setState(() {
        _pay = pays.isNotEmpty
            ? pays
            : _getDummyPayments(); // Fallback a dummy si vacío
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al cargar historial de pagos'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
      setState(() {
        _pay = _getDummyPayments(); // Usar dummy en error
        _isLoading = false;
      });
    }
  }

  // Datos dummy para visualización (hardcodeados, ordenados por fecha descendente)
  List<Pay> _getDummyPayments() {
    return [
      Pay(
        id: '1',
        userId: widget.userId,
        userName: widget.userName,
        dni: '12345678',
        paymentDate: DateTime(2025, 11, 9),
        sentDate: DateTime(2025, 11, 10),
        amount: 20000.0,
        status: PayState.validated,
        comprobantePath: 'comprobante_nov9.pdf',
      ),
      Pay(
        id: '2',
        userId: widget.userId,
        userName: widget.userName,
        dni: '12345678',
        paymentDate: DateTime(2025, 10, 15),
        sentDate: DateTime(2025, 10, 16),
        amount: 20000.0,
        status: PayState.validated,
        comprobantePath: 'comprobante_oct15.pdf',
      ),
      Pay(
        id: '3',
        userId: widget.userId,
        userName: widget.userName,
        dni: '12345678',
        paymentDate: DateTime(2025, 9, 20),
        sentDate: DateTime(2025, 9, 21),
        amount: 20000.0,
        status: PayState.rejected,
        comprobantePath: 'comprobante_sep20.pdf',
      ),
      Pay(
        id: '4',
        userId: widget.userId,
        userName: widget.userName,
        dni: '12345678',
        paymentDate: DateTime(2025, 8, 5),
        sentDate: DateTime(2025, 8, 6),
        amount: 20000.0,
        status: PayState.pending,
        comprobantePath: 'comprobante_aug5.pdf',
      ),
      Pay(
        id: '5',
        userId: widget.userId,
        userName: widget.userName,
        dni: '12345678',
        paymentDate: DateTime(2025, 7, 12),
        sentDate: DateTime(2025, 7, 13),
        amount: 20000.0,
        status: PayState.validated,
        comprobantePath: 'comprobante_jul12.pdf',
      ),
      Pay(
        id: '6',
        userId: widget.userId,
        userName: widget.userName,
        dni: '12345678',
        paymentDate: DateTime(2025, 6, 25),
        sentDate: DateTime(2025, 6, 26),
        amount: 20000.0,
        status: PayState.validated,
        comprobantePath: 'comprobante_jun25.pdf',
      ),
      Pay(
        id: '7',
        userId: widget.userId,
        userName: widget.userName,
        dni: '12345678',
        paymentDate: DateTime(2025, 5, 1),
        sentDate: DateTime(2025, 5, 2),
        amount: 20000.0,
        status: PayState.validated,
        comprobantePath: 'comprobante_may1.pdf',
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
          onPressed: () => context.go(
            '/users/${widget.userId}/view',
          ), // Asumiendo ruta de vuelta a view user
        ),
        title: Text(
          'Historial de Pagos',
          style: TextStyle(
            color: tokens.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
                child: PaymentHistoryContent(
                  payments: _pay,
                  userName: widget.userName,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a página de crear pago para este usuario
          context.go(
            '/payments/create?userId=${widget.userId}', //TODO
          ); // Asumiendo ruta para create
        },
        backgroundColor: tokens.redToRosita,
        child: const Icon(Symbols.add, color: Colors.white),
      ),
    );
  }
}
