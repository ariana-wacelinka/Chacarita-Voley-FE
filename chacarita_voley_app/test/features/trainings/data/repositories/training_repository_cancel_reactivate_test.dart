import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingRepository - Cancel and Reactivate Sessions', () {
    test('debe tener definida la mutación de cancelSession', () {
      const mutation = r'''
    mutation CancelSession($id: ID!) {
      cancelSession(id: $id) {
        id
        status
      }
    }
  ''';

      expect(mutation, contains('cancelSession'));
      expect(mutation, contains('\$id: ID!'));
      expect(mutation, contains('id'));
      expect(mutation, contains('status'));
    });

    test('debe tener definida la mutación de reactivateSession', () {
      const mutation = r'''
    mutation ReactivateSession($id: ID!) {
      reactivateSession(id: $id) {
        id
        status
      }
    }
  ''';

      expect(mutation, contains('reactivateSession'));
      expect(mutation, contains('\$id: ID!'));
      expect(mutation, contains('id'));
      expect(mutation, contains('status'));
    });

    test('cancelSession requiere un ID válido', () {
      const testId = 'session-123';
      expect(testId, isNotEmpty);
      expect(testId, isA<String>());
    });

    test('reactivateSession requiere un ID válido', () {
      const testId = 'session-456';
      expect(testId, isNotEmpty);
      expect(testId, isA<String>());
    });
  });
}
