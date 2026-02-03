class TrainingPreview {
  final String id;
  final String teamName;
  final String startTime;
  final String professorName;
  final int totalPlayers;
  final int attendance;

  TrainingPreview({
    required this.id,
    required this.teamName,
    required this.startTime,
    required this.professorName,
    required this.totalPlayers,
    required this.attendance,
  });

  factory TrainingPreview.fromJson(
    Map<String, dynamic> json,
    String todayDate,
  ) {
    final team = json['team'] as Map<String, dynamic>?;
    final professors = (team?['professors'] as List?) ?? [];

    // Obtener el primer profesor
    String professorName = 'Sin profesor';
    if (professors.isNotEmpty) {
      final firstProf = professors[0] as Map<String, dynamic>;
      final person = firstProf['person'] as Map<String, dynamic>?;
      final name = person?['name'] as String? ?? '';
      final surname = person?['surname'] as String? ?? '';
      professorName = '$surname $name'.trim();
    }

    // Usar countOfPlayers y countOfAssisted si están disponibles
    int totalPlayers = json['countOfPlayers'] as int? ?? 0;
    int attendance = json['countOfAssisted'] as int? ?? 0;

    // Si no están disponibles, calcular desde el array (para compatibilidad)
    if (totalPlayers == 0 && team != null) {
      final players = (team['players'] as List?) ?? [];
      totalPlayers = players.length;

      // Calcular asistencia del día
      for (var player in players) {
        final assistances = (player['assistances'] as List?) ?? [];
        final todayAssistance = assistances.firstWhere(
          (a) => a['date'] == todayDate && a['assistance'] == true,
          orElse: () => null,
        );
        if (todayAssistance != null) {
          attendance++;
        }
      }
    }

    // Usar abbreviation si está disponible, sino name
    String teamName =
        team?['abbreviation'] as String? ??
        team?['name'] as String? ??
        'Sin nombre';

    return TrainingPreview(
      id: json['id'] as String,
      teamName: teamName,
      startTime: json['startTime'] as String? ?? '00:00:00',
      professorName: professorName,
      totalPlayers: totalPlayers,
      attendance: attendance,
    );
  }

  String get formattedTime {
    // Convertir "20:30:00" a "20:30"
    final parts = startTime.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return startTime;
  }
}
