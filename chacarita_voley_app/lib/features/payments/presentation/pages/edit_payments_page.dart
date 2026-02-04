import 'package:chacarita_voley_app/features/payments/domain/mappers/pay_mapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../data/repositories/pay_repository.dart';
import '../../domain/usecases/update_pay_usecase.dart';
import '../widgets/payment_edit_form_widget.dart'; // Import del nuevo widget

class EditPaymentsPage extends StatefulWidget {
  final String paymentId; // O pasa el Payment completo si prefieres

  const EditPaymentsPage({super.key, required this.paymentId});

  @override
  State<EditPaymentsPage> createState() => _EditPaymentsPageState();
}

class _EditPaymentsPageState extends State<EditPaymentsPage> {
  late final UpdatePaymentUseCase _updatePaymentUseCase;
  late final PayRepository _repository;
  Pay? _payment; // El pago a editar (null hasta cargar)
  bool _isLoading = true;

  // Formato de fecha (puedes mover a un util si es global)
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _repository = PayRepository();
    _updatePaymentUseCase = UpdatePaymentUseCase(PayRepository());
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    try {
      final payment = await _repository.getPayById(widget.paymentId);

      if (payment != null) {
        setState(() {
          _payment = payment;
          _isLoading = false;
        });
      } else {
        // Manejar no encontrado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pago no encontrado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: context.tokens.redToRosita,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            ),
          );
          context.go('/payments');
        }
      }
    } catch (e) {
      // Manejar error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al cargar pago')));
      }
    } finally {
      if (mounted && _payment == null) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateBack() {
    final state = GoRouterState.of(context);
    final from = state.uri.queryParameters['from'];
    final userId = state.uri.queryParameters['userId'];

    if (from == 'payment-history' && userId != null) {
      // Usar pop para volver y disparar el .then() en la página de origen
      context.pop();
    } else {
      // Por defecto o si viene de 'validation', volver a la lista de validación
      context.go('/payments');
    }
  }

  Future<void> _handleUpdatePayment(Pay updatedPay) async {
    // setState(() {
    //   _isLoading = true;
    // });
    setState(() => _isLoading = true);

    try {
      await _updatePaymentUseCase.execute(PayMapper.toUpdateInput(updatedPay));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pago modificado exitosamente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: context.tokens.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navegar de vuelta según origen
        _navigateBack();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Error al modificar pago',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: context.tokens.redToRosita,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        // setState(() {
        //   _isLoading = false;
        // });
      }
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
          onPressed: _navigateBack,
        ),
        title: Text(
          'Modificar Pago',
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
          : _payment == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: tokens.gray),
                  const SizedBox(height: 16),
                  Text(
                    'Pago no encontrado',
                    style: TextStyle(
                      color: tokens.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${widget.paymentId}',
                    style: TextStyle(color: tokens.gray, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _navigateBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.redToRosita,
                    ),
                    child: const Text(
                      'Volver a pagos',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: PaymentEditFormWidget(
                payment: _payment!,
                dateFormat: _dateFormat,
                onSave: _handleUpdatePayment,
                isSaving: _isLoading,
              ),
            ),
    );
  }
}
