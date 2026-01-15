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
  final List<String> professorIds; // IDs de profesores (para mutations)
  final List<String> entrenadores; // Nombres completos (para UI)
  final List<TeamMember> integrantes;

  Team({
    required this.id,
    required this.nombre,
    required this.abreviacion,
    required this.tipo,
    List<String>? professorIds,
    List<String>? entrenadores,
    required List<TeamMember> integrantes,
  }) : professorIds = professorIds ?? [],
       entrenadores = entrenadores ?? [],
       integrantes = integrantes.isEmpty ? [] : integrantes;

  int get jugadoresActuales => integrantes.length;

  // Helper para compatibilidad con UI que espera un solo entrenador
  String get entrenador => entrenadores.isNotEmpty ? entrenadores.first : '';
  String? get professorId =>
      professorIds.isNotEmpty ? professorIds.first : null;

  Team copyWith({
    String? nombre,
    String? abreviacion,
    TeamType? tipo,
    List<String>? professorIds,
    List<String>? entrenadores,
    List<TeamMember>? integrantes,
  }) {
    return Team(
      id: id,
      nombre: nombre ?? this.nombre,
      abreviacion: abreviacion ?? this.abreviacion,
      tipo: tipo ?? this.tipo,
      professorIds: professorIds ?? this.professorIds,
      entrenadores: entrenadores ?? this.entrenadores,
      integrantes: integrantes ?? this.integrantes,
    );
  }
}
