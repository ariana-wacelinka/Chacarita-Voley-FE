import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/core/services/auth_service.dart';
import 'package:chacarita_voley_app/features/trainings/data/repositories/training_repository.dart';
import 'package:chacarita_voley_app/features/trainings/domain/entities/training.dart';
import 'package:chacarita_voley_app/features/trainings/presentation/pages/trainings_page.dart';
import 'package:chacarita_voley_app/features/users/data/repositories/user_repository.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTrainingRepository extends TrainingRepository {
  _FakeTrainingRepository() : super();

  @override
  Future<Map<String, dynamic>> getTrainingsWithPagination({
    String? dateFrom,
    String? dateTo,
    String? startTimeFrom,
    String? startTimeTo,
    TrainingStatus? status,
    String? professorId,
    String? teamId,
    String? playerId,
    int page = 0,
    int size = 10,
  }) async {
    return {
      'content': <Training>[],
      'totalPages': 0,
      'totalElements': 0,
      'pageNumber': 0,
      'hasNext': false,
      'hasPrevious': false,
    };
  }
}

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository() : super();

  @override
  Future<User?> getUserById(String id) async => User(
    id: id,
    playerId: 'player-$id',
    dni: '12345678',
    nombre: 'Juan',
    apellido: 'Pérez',
    fechaNacimiento: DateTime(2000, 1, 1),
    genero: Gender.masculino,
    email: 'juan@example.com',
    telefono: '123456789',
    equipo: 'CHR',
    tipos: {UserType.profesor},
    estadoCuota: EstadoCuota.alDia,
  );
}

class _FakeAuthService extends AuthService {
  _FakeAuthService(this.roles, this.userId);

  final List<String> roles;
  final int userId;

  @override
  Future<List<String>?> getUserRoles() async => roles;

  @override
  Future<int?> getUserId() async => userId;
}

Widget _buildApp({
  required TrainingRepository repository,
  required UserRepository userRepository,
  required AuthService authService,
  String? teamId,
  String? teamName,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: TrainingsPage(
      teamId: teamId,
      teamName: teamName,
      repository: repository,
      userRepository: userRepository,
      authService: authService,
    ),
  );
}

void main() {
  testWidgets('TrainingsPage builds correctly with team context', (
    WidgetTester tester,
  ) async {
    final repository = _FakeTrainingRepository();
    final userRepository = _FakeUserRepository();
    final authService = _FakeAuthService(['ADMIN'], 1);

    await tester.pumpWidget(
      _buildApp(
        repository: repository,
        userRepository: userRepository,
        authService: authService,
        teamId: '1',
        teamName: 'Equipo A',
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Filtro'), findsOneWidget);
  });

  testWidgets(
    'TrainingsPage builds with team context even when trainings are global',
    (WidgetTester tester) async {
      final repository = _FakeTrainingRepository();
      final userRepository = _FakeUserRepository();
      final authService = _FakeAuthService(['PROFESSOR'], 42);

      await tester.pumpWidget(
        _buildApp(
          repository: repository,
          userRepository: userRepository,
          authService: authService,
          teamId: '999',
          teamName: 'Equipo Test',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Filtro'), findsOneWidget);
    },
  );
}
