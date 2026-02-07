import 'package:chacarita_voley_app/core/errors/backend_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendErrorMapper', () {
    test('maps known backend codes to friendly messages', () {
      final message = BackendErrorMapper.fromMessage('INVALID_REFRESH_TOKEN');
      expect(message, 'Tu sesion expiro. Inicia sesion nuevamente.');
    });

    test('maps access denied messages', () {
      final message = BackendErrorMapper.fromMessage('Acceso denegado');
      expect(message, 'No tenes permisos para realizar esta accion.');
    });

    test('maps not found messages', () {
      final message = BackendErrorMapper.fromMessage(
        'User not found with id: 10',
      );
      expect(message, 'No se encontro el recurso solicitado.');
    });

    test('maps http status with no body', () {
      final message = BackendErrorMapper.fromHttpResponse(401, '');
      expect(message, 'Sesion expirada. Inicia sesion nuevamente.');
    });

    test('extracts message from json body', () {
      final message = BackendErrorMapper.fromHttpResponse(
        400,
        '{"message":"PERSON_DNI_ALREADY_EXISTS"}',
      );
      expect(message, 'El DNI ya esta registrado.');
    });
  });
}
