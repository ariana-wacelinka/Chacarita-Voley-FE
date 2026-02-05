import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../data/repositories/pay_repository.dart';
import '../widgets/payment_detail_content_widget.dart';

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
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _paymentRepository = PayRepository();
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    setState(() => _isLoading = true);
    try {
      final payment = await _paymentRepository.getPayById(widget.paymentId);
      if (payment != null) {
        setState(() {
          _payment = payment;
          _isLoading = false;
        });
      } else {
        setState(() {
          _notFound = true;
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Pago no encontrado. Regresando a la lista.',
                ),
                backgroundColor: context.tokens.redToRosita,
              ),
            );
            context.go('/payments');
          }
        });
      }
    } catch (e) {
      setState(() {
        _notFound = true;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar detalle del pago: $e'),
              backgroundColor: context.tokens.redToRosita,
            ),
          );
          context.go('/payments');
        }
      });
    }
  }

  void _navigateToEdit() {
    if (_payment != null) {
      context.push('/payments/edit/${_payment!.id}');
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
              backgroundColor: Theme.of(context).colorScheme.primary,
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
