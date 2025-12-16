import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository_interface.dart';

class TeamRepository implements TeamRepositoryInterface {
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
