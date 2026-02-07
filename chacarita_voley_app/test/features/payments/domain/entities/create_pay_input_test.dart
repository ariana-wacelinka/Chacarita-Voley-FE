import 'package:chacarita_voley_app/features/payments/domain/entities/create_pay_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreatePayInput', () {
    test('omits fileName and fileUrl when null', () {
      const input = CreatePayInput(
        dueId: 'due-1',
        date: '2026-02-07',
        amount: 1.5,
        state: 'VALIDATED',
      );

      final json = input.toJson();
      final payload = json['input'] as Map<String, dynamic>;

      expect(payload.containsKey('fileName'), isFalse);
      expect(payload.containsKey('fileUrl'), isFalse);
    });

    test('keeps empty strings when provided', () {
      const input = CreatePayInput(
        dueId: 'due-1',
        date: '2026-02-07',
        amount: 1.5,
        state: 'VALIDATED',
        fileName: '',
        fileUrl: '',
      );

      final json = input.toJson();
      final payload = json['input'] as Map<String, dynamic>;

      expect(payload['fileName'], '');
      expect(payload['fileUrl'], '');
    });
  });
}
