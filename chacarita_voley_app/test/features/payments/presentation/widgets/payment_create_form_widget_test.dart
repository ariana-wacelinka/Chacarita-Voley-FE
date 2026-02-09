import 'dart:convert';

import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/payments/domain/entities/pay_state.dart'
    as payment_state;
import 'package:chacarita_voley_app/features/payments/presentation/widgets/payment_create_form_widget.dart';
import 'package:chacarita_voley_app/features/users/data/repositories/user_repository.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/due.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserRepository extends UserRepository {
  FakeUserRepository({this.user}) : super();

  final User? user;
  final List<String?> queries = [];

  @override
  Future<User?> getUserById(String id) async {
    return user;
  }

  @override
  Future<List<User>> getUsersForPayments({String? searchQuery}) async {
    queries.add(searchQuery);
    return [
      User(
        id: '1',
        playerId: 'p1',
        dni: '12345678',
        nombre: 'Juan',
        apellido: 'Perez',
        fechaNacimiento: DateTime(2000, 1, 1),
        genero: Gender.masculino,
        email: 'juan@example.com',
        telefono: '123456789',
        equipo: 'CHR',
        tipos: {UserType.jugador},
        estadoCuota: EstadoCuota.alDia,
      ),
    ];
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
  test('admin keeps selected status', () {
    final status = resolvePaymentStatus(
      isAdmin: true,
      selectedStatus: payment_state.PayState.validated,
    );

    expect(status, payment_state.PayState.validated);
  });

  test('hasRole is case-insensitive', () {
    final roles = ['player', 'Admin', 'professor'];
    expect(hasRole(roles, 'ADMIN'), isTrue);
    expect(hasRole(roles, 'PLAYER'), isTrue);
  });

  testWidgets('search uses backend filter for payments', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_roles': json.encode(['ADMIN']),
    });

    final repo = FakeUserRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PaymentCreateForm(
              onSave: (_, __, ___) {},
              userRepository: repo,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'juan');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(repo.queries.last, 'juan');
    expect(find.text('Juan Perez'), findsOneWidget);
  });

  testWidgets('player does not trigger user search', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_roles': json.encode(['PLAYER']),
      'user_id': 42,
    });

    final repo = FakeUserRepository(
      user: User(
        id: 'person-42',
        playerId: 'player-42',
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
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PaymentCreateForm(
              onSave: (_, __, ___) {},
              userRepository: repo,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(repo.queries, isEmpty);
  });
}
