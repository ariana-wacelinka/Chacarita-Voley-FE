// import '../../domain/entities/user.dart';
// import '../../domain/entities/gender.dart';
// import '../../domain/repositories/user_repository_interface.dart';

import 'package:chacarita_voley_app/features/payments/Temp/user.dart';
import 'package:chacarita_voley_app/features/payments/Temp/user_repository_interface.dart';

import 'gender.dart';

class UserRepository implements UserRepositoryInterface {
  static final List<User> _users = [
    User(
      id: '1',
      dni: '12345678',
      nombre: 'Juan',
      apellido: 'Pérez',
      fechaNacimiento: DateTime(1990, 5, 15),
      genero: Gender.masculino,
      email: 'juan.perez@email.com',
      telefono: '+54 221 123 4567',
      numeroCamiseta: '10',
      equipo: 'REC1',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.alDia,
    ),
    User(
      id: '2',
      dni: '87654321',
      nombre: 'María',
      apellido: 'González',
      fechaNacimiento: DateTime(1985, 8, 22),
      genero: Gender.femenino,
      email: 'maria.gonzalez@email.com',
      telefono: '+54 221 234 5678',
      numeroCamiseta: '7',
      equipo: 'CHR',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.ultimoPago,
    ),
    User(
      id: '3',
      dni: '23456789',
      nombre: 'Carlos',
      apellido: 'López',
      fechaNacimiento: DateTime(1992, 3, 10),
      genero: Gender.masculino,
      email: 'carlos.lopez@email.com',
      telefono: '+54 221 345 6789',
      numeroCamiseta: '15',
      equipo: 'CHB',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.vencida,
    ),
    User(
      id: '4',
      dni: '34567890',
      nombre: 'Ana',
      apellido: 'Martínez',
      fechaNacimiento: DateTime(1988, 12, 5),
      genero: Gender.femenino,
      email: 'ana.martinez@email.com',
      telefono: '+54 221 456 7890',
      numeroCamiseta: null,
      equipo: 'REC1',
      tipos: {UserType.profesor, UserType.administrador},
      estadoCuota: EstadoCuota.alDia,
    ),
    User(
      id: '5',
      dni: '45678901',
      nombre: 'Luis',
      apellido: 'García',
      fechaNacimiento: DateTime(1995, 7, 18),
      genero: Gender.masculino,
      email: 'luis.garcia@email.com',
      telefono: '+54 221 567 8901',
      numeroCamiseta: '3',
      equipo: 'CHF',
      tipos: {UserType.jugador, UserType.profesor},
      estadoCuota: EstadoCuota.alDia,
    ),
    User(
      id: '6',
      dni: '56789012',
      nombre: 'Sofia',
      apellido: 'Rodríguez',
      fechaNacimiento: DateTime(1993, 11, 30),
      genero: Gender.femenino,
      email: 'sofia.rodriguez@email.com',
      telefono: '+54 221 678 9012',
      numeroCamiseta: '12',
      equipo: 'CHR',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.vencida,
    ),
    User(
      id: '7',
      dni: '67890123',
      nombre: 'Diego',
      apellido: 'Fernández',
      fechaNacimiento: DateTime(1987, 4, 25),
      genero: Gender.masculino,
      email: 'diego.fernandez@email.com',
      telefono: '+54 221 789 0123',
      numeroCamiseta: '9',
      equipo: 'CHB',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.ultimoPago,
    ),
    User(
      id: '8',
      dni: '78901234',
      nombre: 'Valentina',
      apellido: 'Torres',
      fechaNacimiento: DateTime(1991, 9, 12),
      genero: Gender.femenino,
      email: 'valentina.torres@email.com',
      telefono: '+54 221 890 1234',
      numeroCamiseta: '5',
      equipo: 'REC1',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.alDia,
    ),
    User(
      id: '9',
      dni: '89012345',
      nombre: 'Mateo',
      apellido: 'Silva',
      fechaNacimiento: DateTime(1989, 1, 8),
      genero: Gender.masculino,
      email: 'mateo.silva@email.com',
      telefono: '+54 221 901 2345',
      numeroCamiseta: null,
      equipo: 'CHF',
      tipos: {UserType.profesor},
      estadoCuota: EstadoCuota.alDia,
    ),
    User(
      id: '10',
      dni: '90123456',
      nombre: 'Camila',
      apellido: 'Morales',
      fechaNacimiento: DateTime(1994, 6, 20),
      genero: Gender.femenino,
      email: 'camila.morales@email.com',
      telefono: '+54 221 012 3456',
      numeroCamiseta: '8',
      equipo: 'CHR',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.vencida,
    ),
    User(
      id: '11',
      dni: '01234567',
      nombre: 'Sebastián',
      apellido: 'Romero',
      fechaNacimiento: DateTime(1986, 10, 15),
      genero: Gender.masculino,
      email: 'sebastian.romero@email.com',
      telefono: '+54 221 123 4567',
      numeroCamiseta: '11',
      equipo: 'CHB',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.alDia,
    ),
    User(
      id: '12',
      dni: '11234567',
      nombre: 'Isabella',
      apellido: 'Jiménez',
      fechaNacimiento: DateTime(1996, 2, 3),
      genero: Gender.femenino,
      email: 'isabella.jimenez@email.com',
      telefono: '+54 221 234 5678',
      numeroCamiseta: '4',
      equipo: 'REC1',
      tipos: {UserType.jugador},
      estadoCuota: EstadoCuota.ultimoPago,
    ),
    User(
      id: '13',
      dni: '21234567',
      nombre: 'Federico',
      apellido: 'Vargas',
      fechaNacimiento: DateTime(1983, 8, 28),
      genero: Gender.masculino,
      email: 'federico.vargas@email.com',
      telefono: '+54 221 345 6789',
      numeroCamiseta: null,
      equipo: 'CHF',
      tipos: {UserType.administrador},
      estadoCuota: EstadoCuota.alDia,
    ),
  ];

  @override
  List<User> getUsers() {
    return List.from(_users);
  }

  @override
  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> createUser(User user) async {
    final newId = (_users.length + 1).toString();
    final newUser = User(
      id: newId,
      dni: user.dni,
      nombre: user.nombre,
      apellido: user.apellido,
      fechaNacimiento: user.fechaNacimiento,
      genero: user.genero,
      email: user.email,
      telefono: user.telefono,
      numeroCamiseta: user.numeroCamiseta,
      equipo: user.equipo,
      tipos: user.tipos,
      estadoCuota: user.estadoCuota,
    );
    _users.add(newUser);
    return newUser;
  }

  @override
  Future<User> updateUser(User user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      return user;
    }
    throw Exception('Usuario no encontrado');
  }

  @override
  Future<void> deleteUser(String id) async {
    _users.removeWhere((user) => user.id == id);
  }
}
