import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';

void main() {
  group('DueState - EstadoCuota mapping', () {
    test('PAID debe mapear a alDia', () {
      final result = EstadoCuotaExtension.fromDueState(DueState.PAID);
      expect(result, EstadoCuota.alDia);
    });

    test('PENDING debe mapear a ultimoPago', () {
      final result = EstadoCuotaExtension.fromDueState(DueState.PENDING);
      expect(result, EstadoCuota.ultimoPago);
    });

    test('OVERDUE debe mapear a vencida', () {
      final result = EstadoCuotaExtension.fromDueState(DueState.OVERDUE);
      expect(result, EstadoCuota.vencida);
    });

    test('null debe mapear a alDia (default)', () {
      final result = EstadoCuotaExtension.fromDueState(null);
      expect(result, EstadoCuota.alDia);
    });

    test('DueState enum debe tener los valores correctos', () {
      expect(DueState.values.length, 3);
      expect(DueState.values.contains(DueState.PAID), true);
      expect(DueState.values.contains(DueState.PENDING), true);
      expect(DueState.values.contains(DueState.OVERDUE), true);
    });

    test('DueState.PAID name debe ser "PAID"', () {
      expect(DueState.PAID.name, 'PAID');
    });

    test('DueState.PENDING name debe ser "PENDING"', () {
      expect(DueState.PENDING.name, 'PENDING');
    });

    test('DueState.OVERDUE name debe ser "OVERDUE"', () {
      expect(DueState.OVERDUE.name, 'OVERDUE');
    });
  });

  group('EstadoCuota displayName', () {
    test('alDia debe mostrar "Al día"', () {
      expect(EstadoCuota.alDia.displayName, 'Al día');
    });

    test('vencida debe mostrar "Vencida"', () {
      expect(EstadoCuota.vencida.displayName, 'Vencida');
    });

    test('ultimoPago debe mostrar "Último pago"', () {
      expect(EstadoCuota.ultimoPago.displayName, 'Último pago');
    });
  });
}
