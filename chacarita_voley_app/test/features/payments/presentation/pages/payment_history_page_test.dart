import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chacarita_voley_app/features/payments/presentation/pages/payment_history_page.dart';
import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/payments/data/repositories/pay_repository.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_page.dart';
import 'package:chacarita_voley_app/features/users/data/repositories/user_repository.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/due.dart';

class FakePayRepository extends PayRepository {
  String? requestedPlayerId;

  @override
  Future<PayPage> getPaysByPlayerId({
    required String playerId,
    int page = 0,
    int size = 10,
    String? dateFrom,
    String? dateTo,
  }) async {
    requestedPlayerId = playerId;
    return PayPage(
      content: const [],
      totalElements: 0,
      totalPages: 0,
      pageNumber: 0,
      pageSize: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }
}

class FakeUserRepository extends UserRepository {
  FakeUserRepository(this.user);

  final User user;

  @override
  Future<User?> getUserById(String id) async {
    return user;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PaymentHistoryPage uses playerId to load payments', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'user_roles': json.encode([]),
      'user_id': 999,
    });

    final user = User(
      id: 'person-1',
      playerId: 'player-99',
      dni: '123',
      nombre: 'Juan',
      apellido: 'Perez',
      fechaNacimiento: DateTime(2000, 1, 1),
      genero: Gender.masculino,
      email: 'juan@example.com',
      telefono: '123',
      equipo: '',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.alDia,
      currentDue: CurrentDue(
        id: 'due-1',
        period: '2026-02',
        state: DueState.PENDING,
        pay: null,
      ),
    );

    final fakePayRepository = FakePayRepository();
    final fakeUserRepository = FakeUserRepository(user);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PaymentHistoryPage(
          userId: 'person-1',
          userName: 'Juan Perez',
          payRepository: fakePayRepository,
          userRepository: fakeUserRepository,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(fakePayRepository.requestedPlayerId, 'player-99');
  });
}
