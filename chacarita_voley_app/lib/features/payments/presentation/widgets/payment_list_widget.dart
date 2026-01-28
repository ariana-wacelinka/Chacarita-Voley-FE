import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/pay.dart';
import '../../domain/entities/pay_state.dart';

class PaymentListWidget extends StatefulWidget {
  final List<Pay> initialPayments;

  const PaymentListWidget({super.key, required this.initialPayments});

  @override
  State<PaymentListWidget> createState() => _PaymentListWidgetState();
}

class _PaymentListWidgetState extends State<PaymentListWidget> {
  final ScrollController _scrollController = ScrollController();
  List<Pay> _payments = [];
  int _currentPage = 0;
  bool _isLoading = false;
  final int _itemsPerPage = 3;

  @override
  void initState() {
    super.initState();
    _payments = List.from(widget.initialPayments);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // replace with API
  Future<void> _loadMorePayments() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _currentPage++;
      _payments.addAll(_generateDummyPayments(_itemsPerPage));
      _isLoading = false;
    });
  }

  // Generate data dummy
  List<Pay> _generateDummyPayments(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
      (index) => Pay(
        id: 'dummy_${_currentPage}_$index',
        status: PayState.values[index % 3],
        amount: 20.00,
        date: now
            .subtract(Duration(days: index))
            .toIso8601String()
            .split('T')[0],
        time: '10:00:00.000',
        fileName: 'comprobante_$index.pdf',
        fileUrl: 'https://ejemplo.com/comprobante_$index.pdf',
        userName: 'Demas',
        dni: '12345678',
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      // aire arriba/abajo de la lista
      itemCount: _payments.length + (_payments.length >= _itemsPerPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _payments.length) {
          return _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: GFButton(
                    onPressed: _loadMorePayments,
                    text: 'Cargar más',
                    shape: GFButtonShape.pills,
                    color: tokens.blue,
                    textStyle: TextStyle(color: tokens.permanentWhite),
                  ),
                );
        }

        final payment = _payments[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GFCard(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            color: tokens.card1,
            border: Border.all(color: tokens.stroke, width: 1),
            margin: EdgeInsets.zero,
            content: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                // evita que crezca innecesariamente
                children: [
                  // ── Fila superior: Nombre + Badge + Iconos ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                payment.effectiveUserName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tokens.text,
                                  fontSize:
                                      18, // ← bajado de 20 para más seguridad
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  payment.status,
                                  AppTheme(),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _getStatusIcon(payment.status),
                                  const SizedBox(width: 4),
                                  Text(
                                    payment.status.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.visibility_outlined,
                              color: tokens.gray,
                              size: 24,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.description_outlined,
                              color: tokens.gray,
                              size: 24,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'DNI: ${payment.dni}',
                    style: TextStyle(color: tokens.gray, fontSize: 14),
                  ),

                  const SizedBox(height: 12),

                  Divider(color: tokens.stroke, thickness: 1),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateColumn(
                        'Fecha de Pago',
                        dateFormat.format(payment.paymentDate),
                        AppTheme(),
                      ),
                      _buildDateColumn(
                        'Enviado',
                        dateFormat.format(payment.sentDate),
                        AppTheme(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Monto + Acciones ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDateColumn(
                        'Monto',
                        '\$${payment.amount.toStringAsFixed(2)}',
                        AppTheme(),
                      ),
                      _buildActionButtons(payment.status, AppTheme(), payment),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Icon _getStatusIcon(PayState status) {
    switch (status) {
      case PayState.validated:
        return const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
          size: 16, // Ajusta el tamaño según necesites
        );
      case PayState.pending:
        return const Icon(
          Icons.access_time_outlined,
          color: Colors.white,
          size: 16,
        );
      case PayState.rejected:
        return const Icon(Icons.cancel_outlined, color: Colors.white, size: 16);
      default:
        return const Icon(
          Icons.help_outline_outlined,
          color: Colors.white,
          size: 16,
        );
    }
  }

  Color _getStatusColor(PayState status, AppTheme tokens) {
    final tokens = context.tokens;
    switch (status) {
      case PayState.validated:
        return tokens.green;
      case PayState.pending:
        return tokens.pending ?? Colors.orange;
      case PayState.rejected:
        return tokens.redToRosita;
      default:
        return tokens.gray;
    }
  }

  Widget _buildDateColumn(String label, String value, AppTheme tokens) {
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: tokens.gray,
            fontSize: 13,
          ),
        ),
        Text(value, style: TextStyle(color: tokens.text, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons(PayState status, AppTheme tokens, Pay payment) {
    final tokens = context.tokens;
    if (status == PayState.validated) {
      return OutlinedButton.icon(
        onPressed: () => context.go('/payments/edit/${payment.id}'),
        icon: const Icon(Icons.edit, size: 18),
        label: const Text('Modificar', style: TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 36),
          side: BorderSide(color: tokens.gray),
          foregroundColor: tokens.gray,
        ),
      );
    }

    // Pendiente o Rechazado → Aceptar / Rechazar
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 12), // espacio antes del botón combinado
        _buildAcceptRejectButton(
          onAccept: () {
            // Lógica para aprobar / aceptar el pago
            // Ej: actualizar estado a 'aprobado', llamar API, etc.
          },
          onReject: () {
            // Lógica para rechazar
            // Ej: actualizar a 'rechazado', mostrar dialog de confirmación, etc.
          },
          tokens: AppTheme(),
        ),
      ],
    );
  }

  Widget _buildAcceptRejectButton({
    required VoidCallback onAccept,
    required VoidCallback onReject,
    required AppTheme tokens, // o tus colores
  }) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      // pill shape, ajusta según necesites
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(
            // fondo por defecto si quieres (opcional)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mitad izquierda: Aceptar (verde)
              InkWell(
                onTap: onAccept,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: tokens.green, // o Colors.green
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
              // Mitad derecha: Rechazar (rojo)
              InkWell(
                onTap: onReject,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: tokens.redToRosita, // o Colors.red
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
