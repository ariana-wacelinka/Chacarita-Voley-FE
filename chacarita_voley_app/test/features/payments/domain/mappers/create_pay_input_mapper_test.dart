import 'package:chacarita_voley_app/features/payments/domain/entities/pay.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart';
import 'package:chacarita_voley_app/features/payments/domain/mappers/create_pay_input_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildCreatePayInput omits file fields', () {
    final pay = Pay(
      id: 'pay-1',
      status: PayState.validated,
      amount: 10.5,
      date: '2026-02-07',
      fileName: 'local.jpg',
      fileUrl: '/tmp/local.jpg',
      userName: 'Test',
      dni: '12345678',
    );

    final input = buildCreatePayInput(
      newPay: pay,
      dueId: 'due-1',
      isoDate: '2026-02-07',
    );

    expect(input.fileName, isNull);
    expect(input.fileUrl, isNull);
    expect(input.state, 'VALIDATED');
  });
}
