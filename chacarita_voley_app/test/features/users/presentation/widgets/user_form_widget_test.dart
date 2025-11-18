import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';

void main() {
  group('UserFormWidget Entity Integration Tests', () {
    test('should support multi-select user types in User entity', () {
      // Arrange & Act
      final user = User(
        id: '1',
        nombre: 'Test',
        apellido: 'User',
        dni: '12345678',
        fechaNacimiento: DateTime(1990, 1, 1),
        email: 'test@test.com',
        telefono: '+5491123456789',
        genero: Gender.masculino,
        tipos: {UserType.jugador, UserType.profesor, UserType.administrador},
        equipo: 'REC1',
        estadoCuota: EstadoCuota.alDia,
      );

      // Assert
      expect(user.tipos.length, equals(3));
      expect(user.tipos.contains(UserType.jugador), isTrue);
      expect(user.tipos.contains(UserType.profesor), isTrue);
      expect(user.tipos.contains(UserType.administrador), isTrue);
    });

    test('should serialize and deserialize multi-select types correctly', () {
      // Arrange
      final user = User(
        id: '2',
        nombre: 'María',
        apellido: 'González',
        dni: '87654321',
        fechaNacimiento: DateTime(1985, 5, 15),
        email: 'maria@test.com',
        telefono: '+5491187654321',
        genero: Gender.femenino,
        tipos: {UserType.jugador, UserType.profesor},
        equipo: 'CHF',
        estadoCuota: EstadoCuota.alDia,
      );

      // Act
      final json = user.toJson();
      final userFromJson = User.fromJson(json);

      // Assert
      expect(userFromJson.tipos.length, equals(2));
      expect(userFromJson.tipos.contains(UserType.jugador), isTrue);
      expect(userFromJson.tipos.contains(UserType.profesor), isTrue);
    });

    test('should have red shield icon symbol available', () {
      // This test verifies that the icon we want to use exists
      expect(Symbols.shield, isNotNull);
    });

    test('should handle empty string equipo field correctly', () {
      // Test edge case for equipo field
      final user = User(
        id: '3',
        nombre: 'Carlos',
        apellido: 'López',
        dni: '11223344',
        fechaNacimiento: DateTime(1992, 12, 25),
        email: 'carlos@test.com',
        telefono: '+5491199887766',
        genero: Gender.masculino,
        tipos: {UserType.administrador},
        equipo: '', // Empty team
        estadoCuota: EstadoCuota.vencida,
      );

      expect(user.equipo, equals(''));
      expect(user.nombreCompleto, equals('Carlos López'));
    });
  });
}
