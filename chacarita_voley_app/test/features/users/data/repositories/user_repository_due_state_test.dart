import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/due.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';

void main() {
  group('UserRepository - Mapeo de currentDue.state', () {
    test('debe mapear correctamente player con currentDue PAID', () {
      final personData = {
        'id': '1',
        'dni': '12345678',
        'name': 'Juan',
        'surname': 'Perez',
        'roles': ['PLAYER'],
        'player': {
          'id': 'player-1',
          'currentDue': {'state': 'PAID'},
        },
      };

      // Simulamos el mapeo que hace el repositorio
      final player = personData['player'] as Map<String, dynamic>?;
      EstadoCuota estadoCuota = EstadoCuota.alDia;

      if (player != null) {
        final currentDue = player['currentDue'] as Map<String, dynamic>?;
        if (currentDue != null) {
          final stateStr = currentDue['state'] as String?;
          DueState? dueState;
          if (stateStr != null) {
            try {
              dueState = DueState.values.firstWhere((e) => e.name == stateStr);
            } catch (_) {
              dueState = null;
            }
          }
          estadoCuota = EstadoCuotaExtension.fromDueState(dueState);
        }
      }

      expect(estadoCuota, EstadoCuota.alDia);
    });

    test('debe mapear correctamente player con currentDue PENDING', () {
      final personData = {
        'id': '2',
        'dni': '87654321',
        'name': 'Maria',
        'surname': 'Gomez',
        'roles': ['PLAYER'],
        'player': {
          'id': 'player-2',
          'currentDue': {'state': 'PENDING'},
        },
      };

      final player = personData['player'] as Map<String, dynamic>?;
      EstadoCuota estadoCuota = EstadoCuota.alDia;

      if (player != null) {
        final currentDue = player['currentDue'] as Map<String, dynamic>?;
        if (currentDue != null) {
          final stateStr = currentDue['state'] as String?;
          DueState? dueState;
          if (stateStr != null) {
            try {
              dueState = DueState.values.firstWhere((e) => e.name == stateStr);
            } catch (_) {
              dueState = null;
            }
          }
          estadoCuota = EstadoCuotaExtension.fromDueState(dueState);
        }
      }

      expect(estadoCuota, EstadoCuota.ultimoPago);
    });

    test('debe mapear correctamente player con currentDue OVERDUE', () {
      final personData = {
        'id': '3',
        'dni': '11223344',
        'name': 'Carlos',
        'surname': 'Lopez',
        'roles': ['PLAYER'],
        'player': {
          'id': 'player-3',
          'currentDue': {'state': 'OVERDUE'},
        },
      };

      final player = personData['player'] as Map<String, dynamic>?;
      EstadoCuota estadoCuota = EstadoCuota.alDia;

      if (player != null) {
        final currentDue = player['currentDue'] as Map<String, dynamic>?;
        if (currentDue != null) {
          final stateStr = currentDue['state'] as String?;
          DueState? dueState;
          if (stateStr != null) {
            try {
              dueState = DueState.values.firstWhere((e) => e.name == stateStr);
            } catch (_) {
              dueState = null;
            }
          }
          estadoCuota = EstadoCuotaExtension.fromDueState(dueState);
        }
      }

      expect(estadoCuota, EstadoCuota.vencida);
    });

    test('debe usar alDia por defecto cuando player es null', () {
      final personData = {
        'id': '4',
        'dni': '55667788',
        'name': 'Ana',
        'surname': 'Martinez',
        'roles': ['PROFESSOR'],
        'player': null,
      };

      final player = personData['player'] as Map<String, dynamic>?;
      EstadoCuota estadoCuota = EstadoCuota.alDia;

      if (player != null) {
        final currentDue = player['currentDue'] as Map<String, dynamic>?;
        if (currentDue != null) {
          final stateStr = currentDue['state'] as String?;
          DueState? dueState;
          if (stateStr != null) {
            try {
              dueState = DueState.values.firstWhere((e) => e.name == stateStr);
            } catch (_) {
              dueState = null;
            }
          }
          estadoCuota = EstadoCuotaExtension.fromDueState(dueState);
        }
      }

      expect(estadoCuota, EstadoCuota.alDia);
    });

    test('debe usar alDia por defecto cuando currentDue es null', () {
      final personData = {
        'id': '5',
        'dni': '99887766',
        'name': 'Pedro',
        'surname': 'Rodriguez',
        'roles': ['PLAYER'],
        'player': {'id': 'player-5', 'currentDue': null},
      };

      final player = personData['player'] as Map<String, dynamic>?;
      EstadoCuota estadoCuota = EstadoCuota.alDia;

      if (player != null) {
        final currentDue = player['currentDue'] as Map<String, dynamic>?;
        if (currentDue != null) {
          final stateStr = currentDue['state'] as String?;
          DueState? dueState;
          if (stateStr != null) {
            try {
              dueState = DueState.values.firstWhere((e) => e.name == stateStr);
            } catch (_) {
              dueState = null;
            }
          }
          estadoCuota = EstadoCuotaExtension.fromDueState(dueState);
        }
      }

      expect(estadoCuota, EstadoCuota.alDia);
    });

    test('debe manejar estado invalido y usar alDia por defecto', () {
      final personData = {
        'id': '6',
        'dni': '44556677',
        'name': 'Laura',
        'surname': 'Fernandez',
        'roles': ['PLAYER'],
        'player': {
          'id': 'player-6',
          'currentDue': {'state': 'INVALID_STATE'},
        },
      };

      final player = personData['player'] as Map<String, dynamic>?;
      EstadoCuota estadoCuota = EstadoCuota.alDia;

      if (player != null) {
        final currentDue = player['currentDue'] as Map<String, dynamic>?;
        if (currentDue != null) {
          final stateStr = currentDue['state'] as String?;
          DueState? dueState;
          if (stateStr != null) {
            try {
              dueState = DueState.values.firstWhere((e) => e.name == stateStr);
            } catch (_) {
              dueState = null;
            }
          }
          estadoCuota = EstadoCuotaExtension.fromDueState(dueState);
        }
      }

      expect(estadoCuota, EstadoCuota.alDia);
    });
  });
}
