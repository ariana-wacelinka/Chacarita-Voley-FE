import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:chacarita_voley_app/features/payments/presentation/widgets/payment_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('validated payment hides modify button', (tester) async {
    final payment = Pay(
      id: 'pay-1',
      status: PayState.validated,
      amount: 100,
      date: '2026-02-07',
      createdAt: '2026-02-07T10:00:00.000Z',
      userName: 'Test User',
      dni: '12345678',
      fileName: 'comprobante.pdf',
      fileUrl: 'https://example.com/comprobante.pdf',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: PaymentListWidget(initialPayments: [payment])),
      ),
    );

    expect(find.text('Modificar'), findsNothing);
  });
}
