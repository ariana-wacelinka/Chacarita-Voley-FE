import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart'; // to GFCard y GFButton
import 'package:intl/intl.dart';

import '../../data/models/payment.dart';

// Widget list payment with scroll infinity
class PaymentListWidget extends StatefulWidget {
  final List<Payment> initialPayments;

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
    _payments = List.from(widget.initialPayments);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // replace with API)
  Future<void> _loadMorePayments() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    setState(() {
      _currentPage++;
      _payments.addAll(_generateDummyPayments(_itemsPerPage));
      _isLoading = false;
    });
  }

  // Generate data dummy
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
      // +1 for button if there is more
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
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(width: 12.0, height: 10.0),
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
                        icon: Icon(
                          Icons.visibility_outlined,
                          color: tokens.gray,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.description_outlined,
                          color: tokens.gray,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              Text('DNI: ${payment.dni}', style: TextStyle(color: tokens.gray)),
              const SizedBox(height: 1.0),
              Divider(
                color: tokens.strokeToNoStroke,
                thickness: 2.0,
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de Pago',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tokens.gray,
                        ),
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
                      Text(
                        'Enviado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tokens.gray,
                        ),
                      ),
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
                      Text(
                        'Monto',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tokens.gray,
                        ),
                      ),
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
                      icon: Icon(Icons.edit, color: tokens.gray),
                      color: tokens.background,
                      textStyle: TextStyle(color: tokens.text),
                      borderSide: BorderSide(color: tokens.gray),
                    ),
                  if (!showModify)
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GFIconButton(
                            onPressed: () {
                              // Aceptar
                            },
                            icon: const Icon(Icons.check, color: Colors.white),
                            color: tokens.green,
                            shape: GFIconButtonShape.standard,
                            // Forma redondeada
                            padding: EdgeInsets.zero,
                          ),
                          GFIconButton(
                            onPressed: () {
                              // Rechazar
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                            color: tokens.redToRosita,
                            shape: GFIconButtonShape.standard,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
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
