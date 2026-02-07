import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:chacarita_voley_app/features/payments/presentation/widgets/payment_detail_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

void main() {
  testWidgets('set pending action disabled when already pending', (
    tester,
  ) async {
    final payment = Pay(
      id: 'pay-1',
      status: PayState.pending,
      amount: 100,
      date: '2026-02-07',
      createdAt: '2026-02-07T10:00:00.000Z',
      userName: 'Test User',
      dni: '12345678',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: PaymentDetailContent(payment: payment)),
      ),
    );

    await tester.tap(find.byIcon(Symbols.more_vert));
    await tester.pumpAndSettle();

    final item = tester.widget<PopupMenuItem<String>>(
      find.byType(PopupMenuItem<String>),
    );

    expect(item.enabled, isFalse);
  });
}
