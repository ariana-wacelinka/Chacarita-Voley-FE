import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository_interface.dart';

class TeamRepository implements TeamRepositoryInterface {
  static final List<Team> _teams = [
    Team(
      id: '1',
      nombre: 'Chaca Rojo',
      entrenador: 'Ana Martínez',
      jugadoresActuales: 10,
      jugadoresMaximos: 20,
    ),
    Team(
      id: '2',
      nombre: 'Chaca Blanco',
      entrenador: 'Roberto García',
      jugadoresActuales: 2,
      jugadoresMaximos: 20,
    ),
    Team(
      id: '3',
      nombre: 'Chaca Feme',
      entrenador: 'Laura Fernández',
      jugadoresActuales: 15,
      jugadoresMaximos: 20,
    ),
    Team(
      id: '4',
      nombre: 'Chacarita',
      entrenador: 'Diego Rodríguez',
      jugadoresActuales: 15,
      jugadoresMaximos: 20,
    ),
    Team(
      id: '5',
      nombre: 'Recreativo 1',
      entrenador: 'María Sánchez',
      jugadoresActuales: 15,
      jugadoresMaximos: 20,
    ),
  ];

  @override
  Future<List<Team>> getTeams() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_teams);
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
