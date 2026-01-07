import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository_interface.dart';
import '../services/team_service_interface.dart';
import '../models/team_response_model.dart';

class TeamRepository implements TeamRepositoryInterface {
  final TeamServiceInterface? _teamService;

  TeamRepository({TeamServiceInterface? teamService})
    : _teamService = teamService;

  // Equipos hardcodeados - mantenidos para futuros usos/testing

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
    // Lista que se mostrará en la tabla (solo backend)
    final List<Team> displayTeams = [];

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
          displayTeams.add(_mapTeamResponseToTeam(teamModel));
        }
      } catch (e, stackTrace) {
        // Si falla la llamada al backend, devolver lista vacía
        // ignore: avoid_print
        print('❌ Error obteniendo equipos del backend: $e');
        // ignore: avoid_print
        print('Stack trace: $stackTrace');
      }
    } else {
      // ignore: avoid_print
      print('⚠️ TeamService es null, no se pueden obtener equipos');
    }

    // ignore: avoid_print
    print('📊 Total de equipos del backend: ${displayTeams.length}');
    return displayTeams;
  }

  Team _mapTeamResponseToTeam(TeamResponseModel model) {
    return Team(
      id: model.id,
      nombre: model.name,
      abreviacion:
          model.abbreviation ??
          model.name
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
    if (_teamService != null) {
      try {
        // ignore: avoid_print
        print('🔍 Obteniendo equipo por ID: $id del backend...');
        final teamModel = await _teamService.getTeamById(id);
        if (teamModel == null) {
          // ignore: avoid_print
          print('⚠️ Equipo no encontrado en el backend');
          return null;
        }
        // ignore: avoid_print
        print('✅ Equipo encontrado: ${teamModel.name}');
        return _mapTeamResponseToTeam(teamModel);
      } catch (e) {
        // ignore: avoid_print
        print('❌ Error obteniendo equipo del backend: $e');
        rethrow;
      }
    }

    // Fallback a lista local si no hay servicio configurado
    // ignore: avoid_print
    print('⚠️ TeamService es null, usando datos locales');
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _teams.firstWhere((team) => team.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createTeam(Team team) async {
    print('➕ Repository: Intentando crear equipo: ${team.nombre}');

    // Primero crear en el backend si existe el servicio
    if (_teamService != null) {
      try {
        print('📡 Llamando al servicio GraphQL para crear...');
        final request = CreateTeamRequestModel(
          name: team.nombre,
          abbreviation: team.abreviacion,
          isCompetitive: team.tipo == TeamType.competitivo,
          playerIds: team.integrantes.map((m) => m.dni).toList(),
          professorIds: team.entrenador.isNotEmpty ? [team.entrenador] : [],
        );
        await _teamService.createTeam(request);
        print('✅ Equipo creado en el backend');
      } catch (e) {
        print('❌ Error al crear en el backend: $e');
        rethrow;
      }
    } else {
      // Si no hay servicio, solo agregarlo a la lista local
      await Future.delayed(const Duration(milliseconds: 300));
      _teams.add(team);
    }
  }

  @override
  Future<void> updateTeam(Team team) async {
    print(
      '✏️ Repository: Intentando actualizar equipo: ${team.nombre} (ID: ${team.id})',
    );

    // Primero actualizar en el backend si existe el servicio
    if (_teamService != null) {
      try {
        print('📡 Llamando al servicio GraphQL para actualizar...');
        final request = UpdateTeamRequestModel(
          id: team.id,
          name: team.nombre,
          abbreviation: team.abreviacion,
          isCompetitive: team.tipo == TeamType.competitivo,
          playerIds: team.integrantes.map((m) => m.dni).toList(),
          professorIds: team.entrenador.isNotEmpty ? [team.entrenador] : [],
        );
        await _teamService.updateTeam(request);
        print('✅ Equipo actualizado en el backend');
      } catch (e) {
        print('❌ Error al actualizar en el backend: $e');
        rethrow;
      }
    } else {
      // Si no hay servicio, solo actualizar en la lista local
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _teams.indexWhere((t) => t.id == team.id);
      if (index != -1) {
        _teams[index] = team;
      }
    }
  }

  @override
  Future<void> deleteTeam(String id) async {
    // ignore: avoid_print
    print('🗑️ Repository: Eliminando equipo con ID: $id');

    if (_teamService != null) {
      try {
        // ignore: avoid_print
        print('📡 Llamando al servicio GraphQL para eliminar...');
        await _teamService.deleteTeam(id);
        // ignore: avoid_print
        print('✅ Equipo eliminado del backend correctamente');
      } catch (e) {
        // ignore: avoid_print
        print('❌ Error al eliminar del backend: $e');
        rethrow;
      }
    } else {
      throw Exception('No se puede eliminar: TeamService es null');
    }
  }
}
