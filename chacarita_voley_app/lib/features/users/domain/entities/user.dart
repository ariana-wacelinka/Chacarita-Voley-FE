class User {
  final String dni;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final String telefono;
  final String? numeroCamiseta;
  final String equipo;
  final UserType tipo;
  final EstadoCuota estadoCuota;

  User({
    required this.dni,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.telefono,
    this.numeroCamiseta,
    required this.equipo,
    required this.tipo,
    required this.estadoCuota,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      dni: json['dni'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      fechaNacimiento: DateTime.parse(json['fechaNacimiento']),
      telefono: json['telefono'],
      numeroCamiseta: json['numeroCamiseta'],
      equipo: json['equipo'],
      tipo: UserType.values.firstWhere((e) => e.name == json['tipo']),
      estadoCuota: EstadoCuota.values.firstWhere(
        (e) => e.name == json['estadoCuota'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'apellido': apellido,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'telefono': telefono,
      'numeroCamiseta': numeroCamiseta,
      'equipo': equipo,
      'tipo': tipo.name,
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
