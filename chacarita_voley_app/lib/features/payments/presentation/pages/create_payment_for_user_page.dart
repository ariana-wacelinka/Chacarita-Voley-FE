import 'package:chacarita_voley_app/features/payments/domain/mappers/pay_mapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../../app/theme/app_theme.dart';

import '../../../users/domain/entities/user.dart';
import '../../domain/entities/pay.dart';
import '../../domain/usecases/create_pay_usecase.dart';
import '../../data/repositories/pay_repository.dart';
import '../widgets/create_payment_for_user_form_widget.dart';

class CreatePaymentForUserPage extends StatefulWidget {
  final String userId; // Requerido: ID del usuario para pre-cargar

  const CreatePaymentForUserPage({super.key, required this.userId});

  @override
  State<CreatePaymentForUserPage> createState() =>
      _CreatePaymentForUserPageState();
}

class _CreatePaymentForUserPageState extends State<CreatePaymentForUserPage> {
  late final CreatePayUseCase _createPaymentUseCase;
  User? _user; // Usuario pre-cargado
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _createPaymentUseCase = CreatePayUseCase(PayRepository());
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no encontrado')),
          );
          context.go('/users'); // Vuelta a lista de users
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar usuario')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCreatePayment(Pay newPay) async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: usuario no cargado')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _createPaymentUseCase.execute(
        PayMapper.toCreateInput(newPay, _user!),
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
                    'Pago registrado exitosamente para ${_user!.nombreCompleto}',
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
          '/users/${widget.userId}/payments',
        ); // O a historial del usuario
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
          onPressed: () => context.go(
            '/users/${widget.userId}/view',
          ), // Ruta de vuelta a view user
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Registrar Pago',
              style: TextStyle(
                color: tokens.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_user != null)
              Text(
                _user!.nombreCompleto,
                style: TextStyle(color: tokens.gray, fontSize: 14),
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
          : (_user == null
                ? Center(
                    child: Text(
                      'Usuario no encontrado',
                      style: TextStyle(color: tokens.text),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: CreatePaymentForUserForm(
                      user: _user!,
                      onSave: _handleCreatePayment,
                      isSaving: _isLoading,
                    ),
                  )),
    );
  }
}
