import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../data/repositories/pay_repository.dart'; // Asumiendo repo
import '../widgets/payment_detail_content_widget.dart'; // Import del nuevo widget

class PaymentDetailPage extends StatefulWidget {
  final String paymentId; // ID del pago a mostrar
  final String? userName; // Opcional para título si no cargado del pago

  const PaymentDetailPage({super.key, required this.paymentId, this.userName});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  late final PayRepository _paymentRepository;
  Pay? _payment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _paymentRepository = PayRepository();
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
  Pay _getDummyPayment() {
    return Pay(
      id: widget.paymentId,
      status: PayState.pending,
      amount: 20000.0,
      date: '2025-06-12',
      time: '14:30:00.000',
      fileName: 'comprobante_dummy.pdf',
      fileUrl: 'https://ejemplo.com/comprobante_dummy.pdf',
      userName: widget.userName ?? 'Juan Perez',
      dni: '12345678',
    );
  }

  void _navigateToEdit() {
    if (_payment != null) {
      context.go('/payments/edit/${_payment!.id}');
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Detalle del Pago',
              style: TextStyle(
                color: tokens.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_payment != null)
              Text(
                _payment!.player?.person.fullName ??
                    _payment!.userName ??
                    'Sin nombre',
                style: TextStyle(
                  color: tokens.placeholder,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
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
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadPayment,
                child: SingleChildScrollView(
                  child: PaymentDetailContent(payment: _payment!),
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
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
      ),
    );
  }
}
