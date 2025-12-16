class Team {
  final String id;
  final String nombre;
  final String entrenador;
  final int jugadoresActuales;
  final int jugadoresMaximos;

  Team({
    required this.id,
    required this.nombre,
    required this.entrenador,
    required this.jugadoresActuales,
    required this.jugadoresMaximos,
  });

  Team copyWith({
    String? id,
    String? nombre,
    String? entrenador,
    int? jugadoresActuales,
    int? jugadoresMaximos,
  }) {
    return Team(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      entrenador: entrenador ?? this.entrenador,
      jugadoresActuales: jugadoresActuales ?? this.jugadoresActuales,
      jugadoresMaximos: jugadoresMaximos ?? this.jugadoresMaximos,
    );
  }
}
