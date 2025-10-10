import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart'; // Para GFCard y GFButton
import 'package:intl/intl.dart';

import '../../data/models/payment.dart'; // Para formateo de fechas

// Widget de lista de pagos con scroll infinito
class PaymentListWidget extends StatefulWidget {
  final List<Payment>
  initialPayments; // Lista inicial de pagos (podes pasarla desde afuera)

  const PaymentListWidget({super.key, required this.initialPayments});

  @override
  State<PaymentListWidget> createState() => _PaymentListWidgetState();
}

class _PaymentListWidgetState extends State<PaymentListWidget> {
  final ScrollController _scrollController = ScrollController();
  List<Payment> _payments = [];
  int _currentPage = 0;
  bool _isLoading = false;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _payments = List.from(widget.initialPayments); // Copia inicial
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Simula carga de más datos (reemplazá con tu API)
  Future<void> _loadMorePayments() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulación de delay
    setState(() {
      _currentPage++;
      _payments.addAll(_generateDummyPayments(_itemsPerPage));
      _isLoading = false;
    });
  }

  // Genera datos dummy (reemplazá con tu lógica real)
  List<Payment> _generateDummyPayments(int count) {
    final now = DateTime.now();
    return List.generate(
      count,
      (index) => Payment(
        userName: 'Juan Perez',
        dni: '12345678',
        paymentDate: now.subtract(Duration(days: index)),
        sentDate: now.subtract(Duration(days: index - 3)),
        amount: 20.00,
        status: ['Pendiente', 'Aprobado', 'Rechazado'][index % 3],
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
      itemCount: _payments.length + (_payments.length >= _itemsPerPage ? 1 : 0),
      // +1 para botón si hay más
      itemBuilder: (context, index) {
        if (index >= _payments.length) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
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
        Color statusColor;
        IconData statusIcon;
        bool showModify = payment.status == 'Aprobado';

        switch (payment.status) {
          case 'Pendiente':
            statusColor = tokens.pending;
            statusIcon = Icons.circle_outlined;
            break;
          case 'Aprobado':
            statusColor = tokens.green;
            statusIcon = Icons.check_circle_outline;
            break;
          case 'Rechazado':
            statusColor = tokens.redToRosita;
            statusIcon = Icons.cancel_outlined;
            break;
          default:
            statusColor = tokens.gray;
            statusIcon = Icons.help_outline;
        }

        return GFCard(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          boxFit: BoxFit.cover,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 2,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        payment.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tokens.text,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Container(
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        padding: EdgeInsets.all(0.5),
                        child: Text(
                          payment.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.tokens.permanentWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.description),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text('DNI: ${payment.dni}', style: TextStyle(color: tokens.gray)),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de Pago',
                        style: TextStyle(color: tokens.gray),
                      ),
                      Text(
                        dateFormat.format(payment.paymentDate),
                        style: TextStyle(color: tokens.text),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enviado', style: TextStyle(color: tokens.gray)),
                      Text(
                        dateFormat.format(payment.sentDate),
                        style: TextStyle(color: tokens.text),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monto', style: TextStyle(color: tokens.gray)),
                      Text(
                        '\$${payment.amount.toStringAsFixed(2)}',
                        style: TextStyle(color: tokens.text),
                      ),
                    ],
                  ),
                  if (showModify)
                    GFButton(
                      onPressed: () {},
                      text: 'Modificar',
                      shape: GFButtonShape.pills,
                      color: tokens.blue,
                      textStyle: TextStyle(color: tokens.permanentWhite),
                    ),
                  if (!showModify)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: tokens.green,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            color: tokens.redToRosita,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
