import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/assistance.dart';

void main() {
  group('Assistance', () {
    test('debe crear una instancia correctamente desde JSON', () {
      final json = {
        'id': '1',
        'date': '2025-11-09T18:00:00',
        'assistance': true,
      };

      final assistance = Assistance.fromJson(json);

      expect(assistance.id, '1');
      expect(assistance.date, '2025-11-09T18:00:00');
      expect(assistance.assistance, true);
    });

    test('debe convertir una instancia a JSON correctamente', () {
      final assistance = Assistance(
        id: '1',
        date: '2025-11-09T18:00:00',
        assistance: true,
      );

      final json = assistance.toJson();

      expect(json['id'], '1');
      expect(json['date'], '2025-11-09T18:00:00');
      expect(json['assistance'], true);
    });

    test('debe manejar assistance como false', () {
      final json = {
        'id': '2',
        'date': '2025-11-10T18:00:00',
        'assistance': false,
      };

      final assistance = Assistance.fromJson(json);

      expect(assistance.id, '2');
      expect(assistance.date, '2025-11-10T18:00:00');
      expect(assistance.assistance, false);
    });
  });

  group('AssistancePage', () {
    test(
      'debe crear una instancia correctamente desde JSON con datos completos',
      () {
        final json = {
          'content': [
            {'id': '1', 'date': '2025-11-09T18:00:00', 'assistance': true},
            {'id': '2', 'date': '2025-11-10T18:00:00', 'assistance': false},
          ],
          'hasNext': true,
          'hasPrevious': false,
          'pageNumber': 0,
          'pageSize': 10,
          'totalElements': 87,
          'totalPages': 9,
        };

        final assistancePage = AssistancePage.fromJson(json);

        expect(assistancePage.content.length, 2);
        expect(assistancePage.content[0].id, '1');
        expect(assistancePage.content[0].assistance, true);
        expect(assistancePage.content[1].id, '2');
        expect(assistancePage.content[1].assistance, false);
        expect(assistancePage.hasNext, true);
        expect(assistancePage.hasPrevious, false);
        expect(assistancePage.pageNumber, 0);
        expect(assistancePage.pageSize, 10);
        expect(assistancePage.totalElements, 87);
        expect(assistancePage.totalPages, 9);
      },
    );

    test('debe usar valores por defecto cuando faltan campos opcionales', () {
      final json = {'content': []};

      final assistancePage = AssistancePage.fromJson(json);

      expect(assistancePage.content.isEmpty, true);
      expect(assistancePage.hasNext, false);
      expect(assistancePage.hasPrevious, false);
      expect(assistancePage.pageNumber, 0);
      expect(assistancePage.pageSize, 10);
      expect(assistancePage.totalElements, 0);
      expect(assistancePage.totalPages, 0);
    });

    test('debe manejar lista vacía de contenido', () {
      final json = {
        'content': [],
        'hasNext': false,
        'hasPrevious': false,
        'pageNumber': 0,
        'pageSize': 10,
        'totalElements': 0,
        'totalPages': 0,
      };

      final assistancePage = AssistancePage.fromJson(json);

      expect(assistancePage.content.isEmpty, true);
      expect(assistancePage.totalElements, 0);
    });
  });
}
