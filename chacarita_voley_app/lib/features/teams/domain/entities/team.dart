enum TeamType {
  competitivo,
  recreativo;

  String get displayName {
    switch (this) {
      case TeamType.competitivo:
        return 'Competitivo';
      case TeamType.recreativo:
        return 'Recreativo';
    }
  }
}

class TeamMember {
  final String? playerId; // ID del jugador para mutaciones
  final String dni;
  final String nombre;
  final String apellido;
  final String? numeroCamiseta;

  TeamMember({
    this.playerId,
    required this.dni,
    required this.nombre,
    required this.apellido,
    this.numeroCamiseta,
  });

  String get nombreCompleto => '$nombre $apellido';

  TeamMember copyWith({
    String? playerId,
    String? dni,
    String? nombre,
    String? apellido,
    String? numeroCamiseta,
  }) {
    return TeamMember(
      playerId: playerId ?? this.playerId,
      dni: dni ?? this.dni,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      numeroCamiseta: numeroCamiseta ?? this.numeroCamiseta,
    );
  }
}

class Team {
  final String id;
  final String nombre;
  final String abreviacion;
  final TeamType tipo;
  final String entrenador;
  final List<TeamMember> integrantes;

  Team({
    required this.id,
    required this.nombre,
    required this.abreviacion,
    required this.tipo,
    required this.entrenador,
    required List<TeamMember> integrantes,
  }) : integrantes = integrantes.isEmpty ? [] : integrantes;

  int get jugadoresActuales => integrantes.length;

  Team copyWith({
    String? nombre,
    String? abreviacion,
    TeamType? tipo,
    String? entrenador,
    List<TeamMember>? integrantes,
  }) {
    return Team(
      id: id,
      nombre: nombre ?? this.nombre,
      abreviacion: abreviacion ?? this.abreviacion,
      tipo: tipo ?? this.tipo,
      entrenador: entrenador ?? this.entrenador,
      integrantes: integrantes ?? this.integrantes,
    );
  }
}
