import 'package:chacarita_voley_app/features/payments/domain/mappers/pay_mapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/pay.dart';
import '../../domain/usecases/create_pay_usecase.dart';
import '../../data/repositories/pay_repository.dart';
import '../widgets/payment_create_form_widget.dart'; // Import del nuevo widget
import '../../../users/domain/entities/user.dart';

class CreatePaymentPage extends StatefulWidget {
  final String?
  userId; // Opcional: si viene de historial de usuario, pre-cargar

  const CreatePaymentPage({super.key, this.userId});

  @override
  State<CreatePaymentPage> createState() => _CreatePaymentPageState();
}

class _CreatePaymentPageState extends State<CreatePaymentPage> {
  late final CreatePayUseCase _createPaymentUseCase;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _createPaymentUseCase = CreatePayUseCase(PayRepository());
  }

  Future<void> _handleCreatePayment(Pay newPay, User selectedUser) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _createPaymentUseCase.execute(
        PayMapper.toCreateInput(newPay, selectedUser),
      );

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
                Expanded(
                  child: Text(
                    'Pago registrado exitosamente para ${newPay.userName}',
                    style: const TextStyle(
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

        context.go(
          '/payments',
        ); // O a historial si userId presente: '/users/${newPayment.userId}/payments'
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
                    'Error al registrar pago',
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
        setState(() {
          _isLoading = false;
        });
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
          onPressed: () => context.go('/payments'), // O ruta anterior
        ),
        title: Text(
          'Registrar Pago',
          style: TextStyle(
            color: tokens.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.redToRosita),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: PaymentCreateForm(
                  initialUserId: widget.userId,
                  onSave: _handleCreatePayment,
                ),
              ),
      ),
    );
  }
}
