import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/users/presentation/pages/view_user_page.dart';
import 'package:chacarita_voley_app/features/users/data/repositories/user_repository.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';

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

  testWidgets('View user shows full name in personal data', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_roles': json.encode(['ADMIN']),
      'user_id': 1,
    });

    final user = User(
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
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ViewUserPage(
          userId: '1',
          userRepository: FakeUserRepository(user),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final nombreColumn = find.byWidgetPredicate((widget) {
      if (widget is Column) {
        final texts = widget.children
            .whereType<Text>()
            .map((text) => text.data)
            .toList();
        return texts.contains('Nombre') && texts.contains('Juan Perez');
      }
      return false;
    });

    expect(nombreColumn, findsOneWidget);
  });
}
