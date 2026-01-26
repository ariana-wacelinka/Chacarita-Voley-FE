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
    final team = json['team'] as Map<String, dynamic>;
    final players = (team['players'] as List?) ?? [];
    final professors = (team['professors'] as List?) ?? [];

    // Obtener el primer profesor
    String professorName = 'Sin profesor';
    if (professors.isNotEmpty) {
      final firstProf = professors[0] as Map<String, dynamic>;
      final person = firstProf['person'] as Map<String, dynamic>;
      final name = person['name'] as String? ?? '';
      final surname = person['surname'] as String? ?? '';
      professorName = '$surname $name'.trim();
    }

    // Calcular asistencia del día
    int attendance = 0;
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

    return TrainingPreview(
      id: json['id'] as String,
      teamName: team['name'] as String? ?? 'Sin nombre',
      startTime: json['startTime'] as String? ?? '00:00:00',
      professorName: professorName,
      totalPlayers: players.length,
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
