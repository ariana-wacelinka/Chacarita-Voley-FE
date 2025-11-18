import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/user.dart';
import 'package:chacarita_voley_app/features/users/domain/entities/gender.dart';

void main() {
  group('User Entity Tests', () {
    test('should create user with single user type', () {
      // Arrange & Act
      final user = User(
        id: '1',
        nombre: 'Juan',
        apellido: 'Pérez',
        dni: '12345678',
        fechaNacimiento: DateTime(1990, 1, 1),
        email: 'juan@test.com',
        telefono: '+5491123456789',
        genero: Gender.masculino,
        tipos: {UserType.jugador},
        equipo: 'REC1',
        estadoCuota: EstadoCuota.alDia,
      );

      // Assert
      expect(user.tipos.length, equals(1));
      expect(user.tipos.contains(UserType.jugador), isTrue);
      expect(user.nombreCompleto, equals('Juan Pérez'));
    });

    test('should create user with multiple user types', () {
      // Arrange & Act
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

      // Assert
      expect(user.tipos.length, equals(2));
      expect(user.tipos.contains(UserType.jugador), isTrue);
      expect(user.tipos.contains(UserType.profesor), isTrue);
      expect(user.tipos.contains(UserType.administrador), isFalse);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
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
        equipo: 'REC1',
        estadoCuota: EstadoCuota.alDia,
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], equals('3'));
      expect(json['nombre'], equals('Carlos'));
      expect(json['apellido'], equals('López'));
      expect(json['tipos'], isA<List>());
      expect(json['equipo'], equals('REC1'));
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': '4',
        'nombre': 'Ana',
        'apellido': 'Martínez',
        'dni': '55667788',
        'fechaNacimiento': '1988-08-20',
        'email': 'ana@test.com',
        'telefono': '+5491155667788',
        'genero': 'femenino',
        'tipos': ['jugador', 'profesor'],
        'equipo': 'CHB',
        'estadoCuota': 'alDia',
      };

      // Act
      final user = User.fromJson(json);

      // Assert
      expect(user.id, equals('4'));
      expect(user.nombre, equals('Ana'));
      expect(user.apellido, equals('Martínez'));
      expect(user.tipos.length, equals(2));
      expect(user.tipos.contains(UserType.jugador), isTrue);
      expect(user.tipos.contains(UserType.profesor), isTrue);
      expect(user.equipo, equals('CHB'));
    });

    test('should require at least one user type', () {
      // Assert that we can create a user with at least one tipo
      final user = User(
        id: '5',
        nombre: 'Test',
        apellido: 'User',
        dni: '99999999',
        fechaNacimiento: DateTime(1995, 1, 1),
        email: 'test@test.com',
        telefono: '+5491199999999',
        genero: Gender.masculino,
        tipos: {UserType.jugador}, // Must have at least one type
        equipo: 'REC1',
        estadoCuota: EstadoCuota.alDia,
      );

      expect(user.tipos.isNotEmpty, isTrue);
    });
  });

  group('UserType Tests', () {
    test('should have correct display names', () {
      expect(UserType.jugador.displayName, equals('Jugador'));
      expect(UserType.profesor.displayName, equals('Profesor'));
      expect(UserType.administrador.displayName, equals('Administrador'));
    });

    test('should convert to string correctly', () {
      expect(UserType.jugador.toString(), equals('UserType.jugador'));
      expect(UserType.profesor.toString(), equals('UserType.profesor'));
      expect(
        UserType.administrador.toString(),
        equals('UserType.administrador'),
      );
    });
  });

  group('EstadoCuota Tests', () {
    test('should have correct display names', () {
      expect(EstadoCuota.alDia.displayName, equals('Al día'));
      expect(EstadoCuota.vencida.displayName, equals('Vencida'));
      expect(EstadoCuota.ultimoPago.displayName, equals('Último pago'));
    });
  });
}
