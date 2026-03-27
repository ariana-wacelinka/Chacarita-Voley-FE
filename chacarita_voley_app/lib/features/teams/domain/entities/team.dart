import '../../../../core/entities/soft_deletable.dart';
import 'team_type.dart';

class TeamMember with SoftDeletable {
  final String?
  playerId; // ID del jugador para mutaciones relacionadas con player
  final String?
  personId; // ID de la persona para mutaciones relacionadas con person
  final String dni;
  final String nombre;
  final String apellido;
  final String? numeroAfiliado;
  final String? numeroCamiseta;
  @override
  final bool isDeleted;

  TeamMember({
    this.playerId,
    this.personId,
    required this.dni,
    required this.nombre,
    required this.apellido,
    this.numeroAfiliado,
    this.numeroCamiseta,
    this.isDeleted = false,
  });

  String get nombreCompleto => '$nombre $apellido';

  TeamMember copyWith({
    String? playerId,
    String? personId,
    String? dni,
    String? nombre,
    String? apellido,
    String? numeroAfiliado,
    String? numeroCamiseta,
    bool? isDeleted,
  }) {
    return TeamMember(
      playerId: playerId ?? this.playerId,
      personId: personId ?? this.personId,
      dni: dni ?? this.dni,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      numeroAfiliado: numeroAfiliado ?? this.numeroAfiliado,
      numeroCamiseta: numeroCamiseta ?? this.numeroCamiseta,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  TeamMember copyWithIsDeleted(bool value) => copyWith(isDeleted: value);
}

class Team with SoftDeletable {
  final String id;
  final String nombre;
  final String abreviacion;
  final TeamType tipo;
  final List<String> professorIds; // IDs de profesores (para mutations)
  final List<String> entrenadores; // Nombres completos (para UI)
  final List<TeamMember> integrantes;
  @override
  final bool isDeleted;

  Team({
    required this.id,
    required this.nombre,
    required this.abreviacion,
    required this.tipo,
    List<String>? professorIds,
    List<String>? entrenadores,
    required List<TeamMember> integrantes,
    this.isDeleted = false,
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
    bool? isDeleted,
  }) {
    return Team(
      id: id,
      nombre: nombre ?? this.nombre,
      abreviacion: abreviacion ?? this.abreviacion,
      tipo: tipo ?? this.tipo,
      professorIds: professorIds ?? this.professorIds,
      entrenadores: entrenadores ?? this.entrenadores,
      integrantes: integrantes ?? this.integrantes,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Team copyWithIsDeleted(bool value) => copyWith(isDeleted: value);
}
