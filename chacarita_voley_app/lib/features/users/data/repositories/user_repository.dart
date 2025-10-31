import '../../domain/entities/user.dart';
import '../../domain/entities/gender.dart';
import '../../domain/repositories/user_repository_interface.dart';

class UserRepository implements UserRepositoryInterface {
  static final List<User> _users = [
    User(
      id: '1',
      dni: '12345678',
      nombre: 'Juan',
      apellido: 'Perez',
      fechaNacimiento: DateTime(1990, 5, 15),
      genero: Gender.masculino,
      email: 'juan.perez@example.com',
      telefono: '+54 221 123 4567',
      numeroCamiseta: '10',
      equipo: 'REC1',
      tipo: UserType.jugador,
      estadoCuota: EstadoCuota.alDia,
    ),
    User(
      id: '2',
      dni: '87654321',
      nombre: 'Pamela',
      apellido: 'Perez',
      fechaNacimiento: DateTime(1985, 8, 22),
      genero: Gender.femenino,
      email: 'pamela.perez@example.com',
      telefono: '+54 221 234 5678',
      numeroCamiseta: '7',
      equipo: 'CHR',
      tipo: UserType.jugador,
      estadoCuota: EstadoCuota.ultimoPago,
    ),
    User(
      id: '3',
      dni: '23456789',
      nombre: 'Lucio',
      apellido: 'Guerra',
      fechaNacimiento: DateTime(1992, 3, 10),
      genero: Gender.masculino,
      email: 'lucio.guerra@example.com',
      telefono: '+54 221 345 6789',
      numeroCamiseta: '15',
      equipo: 'CHR',
      tipo: UserType.jugador,
      estadoCuota: EstadoCuota.vencida,
    ),
    User(
      id: '4',
      dni: '34567890',
      nombre: 'Ignacio',
      apellido: 'Lanzavecchia',
      fechaNacimiento: DateTime(1988, 12, 5),
      genero: Gender.masculino,
      email: 'ignacio.lanzavecchia@example.com',
      telefono: '+54 221 456 7890',
      numeroCamiseta: null,
      equipo: 'REC1',
      tipo: UserType.profesor,
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
      tipo: user.tipo,
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
