import 'team_type.dart';

/// Modelo ligero para LISTADO de equipos
/// Solo contiene lo necesario para mostrar en la tabla
class TeamListItem {
  final String id;
  final String nombre;
  final String abreviacion;
  final TeamType tipo;
  final int cantidadJugadores;
  final List<String> entrenadores; // Nombres completos para mostrar

  TeamListItem({
    required this.id,
    required this.nombre,
    required this.abreviacion,
    required this.tipo,
    required this.cantidadJugadores,
    required this.entrenadores,
  });

  // Helper para compatibilidad con UI que espera un solo entrenador
  String get entrenador => entrenadores.isNotEmpty ? entrenadores.first : '';
}
