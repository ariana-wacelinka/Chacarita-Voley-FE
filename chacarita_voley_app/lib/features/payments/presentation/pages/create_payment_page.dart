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
  final String? userId;
  final String? userName;

  const CreatePaymentPage({super.key, this.userId, this.userName});

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
    print('🔵 Iniciando creación de pago...');
    print('Usuario: ${selectedUser.nombreCompleto} (${selectedUser.id})');
    print('Monto: ${newPay.amount}');
    print('Fecha: ${newPay.date}');
    print('Archivo: ${newPay.fileName}');
    print('FileURL: ${newPay.fileUrl}');
    print('Estado: ${newPay.status.name}');

    setState(() {
      _isLoading = true;
    });

    try {
      final input = PayMapper.toCreateInput(newPay, selectedUser);
      print('🟡 CreatePayInput generado:');
      print('  - dueId: ${input.dueId}');
      print('  - amount: ${input.amount}');
      print('  - date: ${input.date}');
      print('  - fileName: ${input.fileName}');
      print('  - fileUrl: ${input.fileUrl}');
      print('  - state: ${input.state}');

      print('🟡 Ejecutando mutation createPay...');
      final result = await _createPaymentUseCase.execute(input);
      print('🟢 Pago creado exitosamente! ID: ${result.id}');

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
      print('🔴 ERROR al crear pago:');
      print('Tipo: ${e.runtimeType}');
      print('Mensaje: $e');
      print('Stack trace:');
      print(StackTrace.current);

      // Determinar el mensaje de error apropiado
      String errorMessage = 'Error al registrar pago';

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('payment_already_exists_for_dues')) {
        errorMessage = 'Ya existe un pago registrado para este periodo';
      } else if (errorString.contains('future') ||
          errorString.contains('fecha')) {
        errorMessage = 'La fecha seleccionada no es válida';
      } else if (errorString.contains('invalid') ||
          errorString.contains('failed to convert')) {
        errorMessage = 'Datos inválidos. Verifica los campos';
      } else if (errorString.contains('unauthorized') ||
          errorString.contains('401')) {
        errorMessage = 'Sesión expirada. Por favor, vuelve a iniciar sesión';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
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
            duration: const Duration(seconds: 5),
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
          onPressed: () {
            if (widget.userId != null && widget.userName != null) {
              context.go(
                '/users/${widget.userId}/payments?userName=${Uri.encodeComponent(widget.userName!)}',
              );
            } else {
              context.go('/payments');
            }
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Registrar Pago',
              style: TextStyle(
                color: tokens.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.userName != null)
              Text(
                widget.userName!,
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
