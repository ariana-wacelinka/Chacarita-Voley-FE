import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/assistance.dart';

void main() {
  group('UserRepository - getAllAssistance Integration', () {
    test('debe parsear correctamente la respuesta de getAllAssistance', () {
      final responseData = {
        'content': [
          {'id': '1', 'date': '2025-11-09T18:00:00', 'assistance': true},
          {'id': '2', 'date': '2025-11-09T18:00:00', 'assistance': false},
        ],
        'hasNext': true,
        'hasPrevious': false,
        'pageNumber': 0,
        'pageSize': 10,
        'totalElements': 87,
        'totalPages': 9,
      };

      final assistancePage = AssistancePage.fromJson(responseData);

      expect(assistancePage.content.length, 2);
      expect(assistancePage.content[0].id, '1');
      expect(assistancePage.content[0].assistance, true);
      expect(assistancePage.content[1].id, '2');
      expect(assistancePage.content[1].assistance, false);
      expect(assistancePage.hasNext, true);
      expect(assistancePage.hasPrevious, false);
      expect(assistancePage.totalElements, 87);
      expect(assistancePage.totalPages, 9);
    });

    test('debe manejar respuesta con lista vacía', () {
      final responseData = {
        'content': [],
        'hasNext': false,
        'hasPrevious': false,
        'pageNumber': 0,
        'pageSize': 10,
        'totalElements': 0,
        'totalPages': 0,
      };

      final assistancePage = AssistancePage.fromJson(responseData);

      expect(assistancePage.content.isEmpty, true);
      expect(assistancePage.totalElements, 0);
      expect(assistancePage.hasNext, false);
    });

    test('debe manejar múltiples páginas de asistencias', () {
      final page1Data = {
        'content': [
          {'id': '1', 'date': '2025-11-09T18:00:00', 'assistance': true},
        ],
        'hasNext': true,
        'hasPrevious': false,
        'pageNumber': 0,
        'pageSize': 1,
        'totalElements': 3,
        'totalPages': 3,
      };

      final page1 = AssistancePage.fromJson(page1Data);
      expect(page1.hasNext, true);
      expect(page1.hasPrevious, false);
      expect(page1.pageNumber, 0);

      final page2Data = {
        'content': [
          {'id': '2', 'date': '2025-11-10T18:00:00', 'assistance': false},
        ],
        'hasNext': true,
        'hasPrevious': true,
        'pageNumber': 1,
        'pageSize': 1,
        'totalElements': 3,
        'totalPages': 3,
      };

      final page2 = AssistancePage.fromJson(page2Data);
      expect(page2.hasNext, true);
      expect(page2.hasPrevious, true);
      expect(page2.pageNumber, 1);
    });

    test('debe parsear correctamente diferentes formatos de fecha', () {
      final testCases = [
        '2025-11-09T18:00:00',
        '2025-11-09T18:00:00.000',
        '2025-11-09T18:00:00Z',
        '2025-11-09T18:00:00.000Z',
      ];

      for (final dateString in testCases) {
        final responseData = {
          'content': [
            {'id': '1', 'date': dateString, 'assistance': true},
          ],
          'hasNext': false,
          'hasPrevious': false,
          'pageNumber': 0,
          'pageSize': 10,
          'totalElements': 1,
          'totalPages': 1,
        };

        final assistancePage = AssistancePage.fromJson(responseData);
        expect(assistancePage.content[0].date, dateString);
      }
    });
  });
}
