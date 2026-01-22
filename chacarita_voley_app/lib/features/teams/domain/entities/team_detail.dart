import 'team.dart';
import 'team_type.dart';

/// Modelo completo para DETALLE de equipo
/// Incluye toda la información necesaria para ViewTeam y EditTeam
class TeamDetail {
  final String id;
  final String nombre;
  final String abreviacion;
  final TeamType tipo;
  final List<String> professorIds; // IDs de profesores (para mutations)
  final List<String> entrenadores; // Nombres completos (para UI)
  final List<TeamMember> integrantes;
  final List<Training> entrenamientos;

  TeamDetail({
    required this.id,
    required this.nombre,
    required this.abreviacion,
    required this.tipo,
    List<String>? professorIds,
    List<String>? entrenadores,
    required List<TeamMember> integrantes,
    List<Training>? entrenamientos,
  }) : professorIds = professorIds ?? [],
       entrenadores = entrenadores ?? [],
       integrantes = integrantes.isEmpty ? [] : integrantes,
       entrenamientos = entrenamientos ?? [];

  int get jugadoresActuales => integrantes.length;

  // Helper para compatibilidad con UI que espera un solo entrenador
  String get entrenador => entrenadores.isNotEmpty ? entrenadores.first : '';
  String? get professorId =>
      professorIds.isNotEmpty ? professorIds.first : null;

  TeamDetail copyWith({
    String? nombre,
    String? abreviacion,
    TeamType? tipo,
    List<String>? professorIds,
    List<String>? entrenadores,
    List<TeamMember>? integrantes,
    List<Training>? entrenamientos,
  }) {
    return TeamDetail(
      id: id,
      nombre: nombre ?? this.nombre,
      abreviacion: abreviacion ?? this.abreviacion,
      tipo: tipo ?? this.tipo,
      professorIds: professorIds ?? this.professorIds,
      entrenadores: entrenadores ?? this.entrenadores,
      integrantes: integrantes ?? this.integrantes,
      entrenamientos: entrenamientos ?? this.entrenamientos,
    );
  }
}

class Training {
  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? location;
  final String? trainingType;

  Training({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
    this.trainingType,
  });
}
