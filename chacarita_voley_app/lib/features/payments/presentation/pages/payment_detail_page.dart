import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/payment.dart';
import '../../data/repositories/payment_repository.dart'; // Asumiendo repo
import '../widgets/payment_detail_content_widget.dart'; // Import del nuevo widget

class PaymentDetailPage extends StatefulWidget {
  final String paymentId; // ID del pago a mostrar
  final String? userName; // Opcional para título si no cargado del pago

  const PaymentDetailPage({super.key, required this.paymentId, this.userName});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  late final PaymentRepository _paymentRepository;
  Payment? _payment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _paymentRepository = PaymentRepository();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    try {
      final payment = _paymentRepository.getPaymentById(widget.paymentId);
      setState(() {
        _payment = payment ?? _getDummyPayment(); // Fallback a dummy
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al cargar detalle del pago'),
            backgroundColor: context.tokens.redToRosita,
          ),
        );
      }
      setState(() {
        _payment = _getDummyPayment(); // Usar dummy en error
        _isLoading = false;
      });
    }
  }

  // Dummy data para visualización
  Payment _getDummyPayment() {
    return Payment(
      id: widget.paymentId,
      userId: 'dummy_user_id',
      userName: widget.userName ?? 'Juan Perez',
      dni: '12345678',
      paymentDate: DateTime(2025, 6, 12, 14, 30),
      // Con hora para display
      sentDate: DateTime(2025, 6, 15),
      amount: 20000.0,
      status: PaymentStatus.pendiente,
      comprobantePath: 'comprobante_dummy.pdf',
      notes: 'Pendiente de revisión',
    );
  }

  void _navigateToEdit() {
    if (_payment != null) {
      context.go('/payments/${_payment!.id}/edit');
    }
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
          onPressed: () =>
              context.go('/payments'), // Vuelta a lista o historial
        ),
        title: Text(
          'Detalle del Pago',
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
              onRefresh: _loadPayment,
              child: SingleChildScrollView(
                child: PaymentDetailContent(payment: _payment!),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _navigateToEdit,
          icon: const Icon(Symbols.edit, color: Colors.white),
          label: const Text(
            'Modificar Pago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.redToRosita,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
