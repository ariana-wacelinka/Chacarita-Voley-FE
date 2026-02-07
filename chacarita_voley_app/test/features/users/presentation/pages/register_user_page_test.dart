import 'dart:convert';

import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/assistance.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/assistance_stats.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:chacarita_voley_app/features/users/domain/repositories/user_repository_interface.dart';
import 'package:chacarita_voley_app/features/users/domain/usecases/create_user_usecase.dart';
import 'package:chacarita_voley_app/features/users/presentation/pages/register_user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserRepository implements UserRepositoryInterface {
  @override
  Future<User> createUser(User user) async => user;

  @override
  Future<void> deleteUser(String id) async => Future.value();

  @override
  Future<List<User>> getUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
    bool? playerIsCompetitive,
    int? page,
    int? size,
    bool forTeamSelection = false,
  }) async => [];

  @override
  Future<int> getTotalUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
  }) async => 0;

  @override
  Future<User?> getUserById(String id) async => null;

  @override
  Future<User> updateUser(User user) async => user;

  @override
  Future<AssistancePage> getAllAssistance({
    required String playerId,
    String? startTimeFrom,
    String? endTimeTo,
    required int page,
    required int size,
  }) async => throw UnimplementedError();

  @override
  Future<AssistanceStats> getAssistanceStatsByPlayerId(String playerId) async =>
      throw UnimplementedError();
}

void main() {
  testWidgets('register page pops with true on success', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_roles': json.encode(['ADMIN']),
    });

    final useCase = CreateUserUseCase(FakeUserRepository());
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/register'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              RegisterUserPage(createUserUseCase: useCase),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(RegisterUserPage)) as dynamic;

    final user = User(
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
    );

    await state.handleSaveUserForTest(user);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterUserPage), findsNothing);
  });
}
