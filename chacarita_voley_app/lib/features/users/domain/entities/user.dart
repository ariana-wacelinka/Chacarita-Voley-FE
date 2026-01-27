import 'due.dart';
import 'gender.dart';

class TeamInfo {
  final String id;
  final String name;
  final String abbreviation;
  final bool isCompetitive;

  TeamInfo({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.isCompetitive,
  });
}

class User {
  final String? id;
  final String? playerId;
  final String? professorId;
  final String dni;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final Gender genero;
  final String email;
  final String telefono;
  final String? numeroCamiseta;
  final String? numeroAfiliado;
  final String equipo;
  final List<TeamInfo> equipos;
  final Set<UserType> tipos;
  final EstadoCuota estadoCuota;
  final CurrentDue? currentDue;

  User({
    this.id,
    this.playerId,
    this.professorId,
    required this.dni,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.genero,
    required this.email,
    required this.telefono,
    this.numeroCamiseta,
    this.numeroAfiliado,
    required this.equipo,
    this.equipos = const [],
    required this.tipos,
    required this.estadoCuota,
    this.currentDue,
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
      numeroAfiliado: json['numeroAfiliado'],
      equipo: json['equipo'],
      equipos:
          (json['equipos'] as List<dynamic>?)
              ?.map(
                (e) => TeamInfo(
                  id: e['id'] as String,
                  name: e['name'] as String,
                  abbreviation: e['abbreviation'] as String,
                  isCompetitive: e['isCompetitive'] as bool,
                ),
              )
              .toList() ??
          [],
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
      'equipos': equipos
          .map(
            (e) => {
              'id': e.id,
              'name': e.name,
              'abbreviation': e.abbreviation,
              'isCompetitive': e.isCompetitive,
            },
          )
          .toList(),
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

  static EstadoCuota fromDueState(DueState? state) {
    if (state == null) return EstadoCuota.alDia;
    switch (state) {
      case DueState.PAID:
        return EstadoCuota.alDia;
      case DueState.PENDING:
        return EstadoCuota.ultimoPago;
      case DueState.OVERDUE:
        return EstadoCuota.vencida;
    }
  }
}
