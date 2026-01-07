import 'gender.dart';

class User {
  final String? id;
  final String? playerId; // ID del player (si es jugador)
  final String dni;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final Gender genero;
  final String email;
  final String telefono;
  final String? numeroCamiseta;
  final String equipo;
  final Set<UserType> tipos;
  final EstadoCuota estadoCuota;

  User({
    this.id,
    this.playerId,
    required this.dni,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.genero,
    required this.email,
    required this.telefono,
    this.numeroCamiseta,
    required this.equipo,
    required this.tipos,
    required this.estadoCuota,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      playerId: json['playerId'],
      dni: json['dni'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: DateTime.parse(json['fechaNacimiento']),
      genero: Gender.values.firstWhere((e) => e.name == json['genero']),
      email: json['email'],
      telefono: json['telefono'],
      numeroCamiseta: json['numeroCamiseta'],
      equipo: json['equipo'],
      tipos: (json['tipos'] as List<dynamic>)
          .map((e) => UserType.values.firstWhere((type) => type.name == e))
          .toSet(),
      estadoCuota: EstadoCuota.values.firstWhere(
        (e) => e.name == json['estadoCuota'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dni': dni,
      'nombre': nombre,
      'apellido': apellido,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'genero': genero.name,
      'email': email,
      'telefono': telefono,
      'numeroCamiseta': numeroCamiseta,
      'equipo': equipo,
      'tipos': tipos.map((e) => e.name).toList(),
      'estadoCuota': estadoCuota.name,
    };
  }
}

enum UserType { jugador, profesor, administrador }

enum EstadoCuota { alDia, vencida, ultimoPago }

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.jugador:
        return 'Jugador';
      case UserType.profesor:
        return 'Profesor';
      case UserType.administrador:
        return 'Administrador';
    }
  }
}

extension EstadoCuotaExtension on EstadoCuota {
  String get displayName {
    switch (this) {
      case EstadoCuota.alDia:
        return 'Al día';
      case EstadoCuota.vencida:
        return 'Vencida';
      case EstadoCuota.ultimoPago:
        return 'Último pago';
    }
  }
}
