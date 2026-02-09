import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chacarita_voley_app/app/di.dart';
import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/home/presentation/pages/home_page.dart';
import 'package:chacarita_voley_app/features/home/data/repositories/home_repository.dart';
import 'package:chacarita_voley_app/features/home/domain/models/home_stats.dart';
import 'package:chacarita_voley_app/features/home/domain/models/notification_preview.dart';
import 'package:chacarita_voley_app/features/home/domain/models/training_preview.dart';
import 'package:chacarita_voley_app/features/home/domain/models/delivery_preview.dart';
import 'package:chacarita_voley_app/features/users/data/repositories/user_repository.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/due.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';

class FakeHomeRepository extends HomeRepository {
  int getStatsCalls = 0;
  int getScheduledNotificationsCalls = 0;
  int getTodayTrainingsCalls = 0;
  int getPlayerDeliveriesCalls = 0;
  int getPlayerTrainingsCalls = 0;
  String? lastDeliveriesPersonId;
  String? lastTrainingsPlayerId;

  @override
  Future<HomeStats> getStats() async {
    getStatsCalls++;
    return HomeStats.empty();
  }

  @override
  Future<List<NotificationPreview>> getScheduledNotifications() async {
    getScheduledNotificationsCalls++;
    return [];
  }

  @override
  Future<List<TrainingPreview>> getTodayTrainings() async {
    getTodayTrainingsCalls++;
    return [];
  }

  @override
  Future<List<DeliveryPreview>> getPlayerDeliveries(String personId) async {
    getPlayerDeliveriesCalls++;
    lastDeliveriesPersonId = personId;
    return [];
  }

  @override
  Future<List<TrainingPreview>> getPlayerTrainings(String playerId) async {
    getPlayerTrainingsCalls++;
    lastTrainingsPlayerId = playerId;
    return [];
  }
}

class FakeUserRepository extends UserRepository {
  FakeUserRepository(this.user);

  final User user;

  @override
  Future<User?> getUserById(String id) async {
    return user;
  }

  @override
  Future<List<CurrentDue>> getAllDuesByPlayerId(
    String playerId, {
    List<DueState>? states,
  }) async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Player home does not request admin stats', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_roles': json.encode(['PLAYER']),
      'user_id': 10,
    });

    final fakeRepository = FakeHomeRepository();
    final fakeUserRepository = FakeUserRepository(
      User(
        id: 'person-10',
        playerId: 'player-99',
        dni: '12345678',
        nombre: 'Jugador',
        apellido: 'Uno',
        fechaNacimiento: DateTime(2000, 1, 1),
        genero: Gender.masculino,
        email: 'jugador@example.com',
        telefono: '123456789',
        equipo: 'CHR',
        tipos: {UserType.jugador},
        estadoCuota: EstadoCuota.alDia,
        currentDue: CurrentDue(
          id: 'due-1',
          period: '2026-02',
          state: DueState.PENDING,
          pay: null,
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeRepositoryProvider.overrideWithValue(fakeRepository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: HomePage(userRepository: fakeUserRepository),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(fakeRepository.getStatsCalls, 0);
    expect(fakeRepository.getScheduledNotificationsCalls, 0);
    expect(fakeRepository.getTodayTrainingsCalls, 0);
    expect(fakeRepository.getPlayerDeliveriesCalls, 1);
    expect(fakeRepository.getPlayerTrainingsCalls, 1);
    expect(fakeRepository.lastDeliveriesPersonId, '10');
    expect(fakeRepository.lastTrainingsPlayerId, 'player-99');
  });
}
