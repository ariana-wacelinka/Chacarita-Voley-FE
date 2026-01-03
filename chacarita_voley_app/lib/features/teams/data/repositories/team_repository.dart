import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository_interface.dart';
import '../services/team_service_interface.dart';
import '../models/team_response_model.dart';

class TeamRepository implements TeamRepositoryInterface {
  final TeamServiceInterface? _teamService;

  TeamRepository({TeamServiceInterface? teamService})
    : _teamService = teamService;

  static final List<Team> _teams = [
    Team(
      id: '1',
      nombre: 'Chaca Rojo',
      abreviacion: 'CHR',
      tipo: TeamType.competitivo,
      entrenador: 'Ana Martínez',
      integrantes: [
        TeamMember(
          dni: '12345678',
          nombre: 'Juan',
          apellido: 'Pérez',
          numeroCamiseta: '10',
        ),
        TeamMember(
          dni: '23456789',
          nombre: 'Carlos',
          apellido: 'López',
          numeroCamiseta: '7',
        ),
      ],
    ),
    Team(
      id: '2',
      nombre: 'Chaca Blanco',
      abreviacion: 'CHB',
      tipo: TeamType.competitivo,
      entrenador: 'Roberto García',
      integrantes: [
        TeamMember(
          dni: '34567890',
          nombre: 'Miguel',
          apellido: 'Sánchez',
          numeroCamiseta: '15',
        ),
      ],
    ),
    Team(
      id: '3',
      nombre: 'Chaca Feme',
      abreviacion: 'CHF',
      tipo: TeamType.competitivo,
      entrenador: 'Laura Fernández',
      integrantes: [
        TeamMember(
          dni: '45678901',
          nombre: 'María',
          apellido: 'González',
          numeroCamiseta: '5',
        ),
        TeamMember(
          dni: '56789012',
          nombre: 'Paula',
          apellido: 'Martínez',
          numeroCamiseta: '12',
        ),
      ],
    ),
    Team(
      id: '4',
      nombre: 'Chacarita',
      abreviacion: 'CHA',
      tipo: TeamType.competitivo,
      entrenador: 'Diego Rodríguez',
      integrantes: [
        TeamMember(
          dni: '67890123',
          nombre: 'Fernando',
          apellido: 'Flores',
          numeroCamiseta: '9',
        ),
      ],
    ),
    Team(
      id: '5',
      nombre: 'Recreativo 1',
      abreviacion: 'REC',
      tipo: TeamType.recreativo,
      entrenador: 'María Sánchez',
      integrantes: [
        TeamMember(dni: '78901234', nombre: 'Jorge', apellido: 'Díaz'),
      ],
    ),
  ];

  @override
  Future<List<Team>> getTeams() async {
    final List<Team> allTeams = List.from(_teams);

    // Intentar obtener equipos del backend
    if (_teamService != null) {
      try {
        // ignore: avoid_print
        print('🔍 Obteniendo equipos del backend...');
        final backendTeams = await _teamService.getTeams();
        // ignore: avoid_print
        print('✅ Equipos obtenidos del backend: ${backendTeams.length}');
        // Convertir TeamResponseModel a Team
        for (final teamModel in backendTeams) {
          // ignore: avoid_print
          print(
            '📦 Procesando equipo: ${teamModel.name} (ID: ${teamModel.id})',
          );
          allTeams.add(_mapTeamResponseToTeam(teamModel));
        }
      } catch (e, stackTrace) {
        // Si falla la llamada al backend, solo usar equipos hardcodeados
        // ignore: avoid_print
        print('❌ Error obteniendo equipos del backend: $e');
        // ignore: avoid_print
        print('Stack trace: $stackTrace');
      }
    } else {
      // ignore: avoid_print
      print('⚠️ TeamService es null, solo usando equipos hardcodeados');
    }

    // ignore: avoid_print
    print('📊 Total de equipos: ${allTeams.length}');
    return allTeams;
  }

  Team _mapTeamResponseToTeam(TeamResponseModel model) {
    return Team(
      id: model.id,
      nombre: model.name,
      abreviacion: model.name
          .substring(0, model.name.length > 4 ? 4 : model.name.length)
          .toUpperCase(),
      tipo: model.isCompetitive ? TeamType.competitivo : TeamType.recreativo,
      entrenador: (model.professors != null && model.professors!.isNotEmpty)
          ? model.professors!.first.id
          : '',
      integrantes: (model.players ?? [])
          .map(
            (player) => TeamMember(
              dni: player.id,
              nombre: '',
              apellido: '',
              numeroCamiseta: player.jerseyNumber,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Team?> getTeamById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _teams.firstWhere((team) => team.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createTeam(Team team) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _teams.add(team);
  }

  @override
  Future<void> updateTeam(Team team) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _teams.indexWhere((t) => t.id == team.id);
    if (index != -1) {
      _teams[index] = team;
    }
  }

  @override
  Future<void> deleteTeam(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _teams.removeWhere((team) => team.id == id);
  }
}
