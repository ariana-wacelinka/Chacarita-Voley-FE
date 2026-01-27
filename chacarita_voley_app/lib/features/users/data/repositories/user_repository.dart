import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
import '../../domain/entities/assistance.dart';
import '../../domain/entities/assistance_stats.dart';
import '../../domain/entities/due.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository_interface.dart';

class UserRepository implements UserRepositoryInterface {
  UserRepository({GraphQLClient? graphQLClient})
    : _clientOverride = graphQLClient;

  final GraphQLClient? _clientOverride;

  Future<QueryResult> _query(QueryOptions options) {
    final override = _clientOverride;
    if (override != null) return override.query(options);
    return GraphQLClientFactory.client.query(options);
  }

  Future<QueryResult> _mutate(MutationOptions options) {
    final override = _clientOverride;
    if (override != null) return override.mutate(options);
    return GraphQLClientFactory.client.mutate(options);
  }

  // Query mínima para LISTADOS - Solo lo necesario para mostrar en tabla
  // NO incluye relaciones para evitar N+1 y timeout
  static const String _personFieldsMinimal = r'''
    id
    dni
    name
    surname
    roles
    player {
      id
      currentDue {
        id
        state
        period
      }
      teams {
        id
        abbreviation
      }
    }
  ''';

  // Query para selección en equipos - Incluye IDs necesarios
  static const String _personFieldsForTeams = r'''
    id
    dni
    name
    surname
    roles
    player {
      id
      jerseyNumber
      leagueId
    }
    professor {
      id
    }
  ''';

  // Query ultra liviana para notificaciones - Solo id, nombre y apellido
  static const String _personFieldsForNotifications = r'''
    id
    name
    surname
  ''';

  // Query completa para DETALLE (ver/editar usuario)
  static const String _personFields = r'''
    id
    dni
    email
    gender
    name
    phone
    roles
    surname
    birthDate
    player {
      id
      leagueId
      jerseyNumber
      teams { id isCompetitive name abbreviation }
      dues { id }
      assistances { id }
      currentDue {
        state
        period
        pay {
          time
          state
          id
          fileUrl
          fileName
          date
          amount
        }
        id
      }
    }
    professor {
      id
    }
  ''';

  String _getAllPersonsQuery() =>
      '''
    query GetAllPersons(\$page: Int!, \$size: Int!, \$search: String, \$role: Role, \$statusCurrentDue: DuesState) {
      getAllPersons(page: \$page, size: \$size, filters: {search: \$search, role: \$role, statusCurrentDue: \$statusCurrentDue}) {
        content {
          $_personFieldsMinimal
        }
        hasNext
        hasPrevious
        pageNumber
        pageSize
        totalElements
        totalPages
      }
    }
  ''';

  String _getAllPersonsForTeamsQuery() =>
      '''
    query GetAllPersonsForTeams(\$page: Int!, \$size: Int!, \$dni: String, \$name: String, \$surname: String, \$role: Role) {
      getAllPersons(page: \$page, size: \$size, filters: {dni: \$dni, name: \$name, surname: \$surname, role: \$role}) {
        content {
          $_personFieldsForTeams
        }
        hasNext
        hasPrevious
        pageNumber
        pageSize
        totalElements
        totalPages
      }
    }
  ''';

  String _getAllPersonsForNotificationsQuery() =>
      '''
    query GetAllPersonsForNotifications(\$page: Int!, \$size: Int!) {
      getAllPersons(page: \$page, size: \$size) {
        content {
          $_personFieldsForNotifications
        }
        totalElements
      }
    }
  ''';

  String _getPersonByIdQuery() =>
      '''
    query GetPersonById(\$id: ID!) {
      getPersonById(id: \$id) {
        $_personFields
      }
    }
  ''';

  String _createPersonMutation() =>
      '''
    mutation CreatePerson(\$input: CreatePersonInput!) {
      createPerson(input: \$input) {
        $_personFields
      }
    }
  ''';

  String _updatePersonMutation() =>
      '''
    mutation UpdatePerson(\$id: ID!, \$input: UpdatePersonInput!) {
      updatePerson(id: \$id, input: \$input) {
        $_personFields
      }
    }
  ''';

  static const String _deletePlayerMutation = r'''
    mutation DeletePlayer($id: ID!) {
      deletePlayer(id: $id)
    }
  ''';

  static const String _deleteProfessorMutation = r'''
    mutation DeleteProfessor($id: ID!) {
      deleteProfessor(id: $id)
    }
  ''';

  /// Construye los filtros para el backend
  /// Ahora el backend maneja la búsqueda con OR en un solo parámetro 'search'
  Map<String, dynamic> _buildFilters({
    String? searchQuery,
    String? role,
    String? statusCurrentDue,
  }) {
    return {
      'search': searchQuery?.trim() ?? '',
      'role': role,
      'statusCurrentDue': statusCurrentDue,
    };
  }

  @override
  Future<List<User>> getUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
    int? page,
    int? size,
    bool forTeamSelection = false,
  }) async {
    final filters = _buildFilters(
      searchQuery: searchQuery,
      role: role,
      statusCurrentDue: statusCurrentDue,
    );

    final result = await _query(
      QueryOptions(
        document: gql(
          forTeamSelection
              ? _getAllPersonsForTeamsQuery()
              : _getAllPersonsQuery(),
        ),
        variables: {'page': page ?? 0, 'size': size ?? 12, ...filters},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final content =
        (result.data?['getAllPersons']?['content'] as List<dynamic>?) ??
        const [];

    return content
        .whereType<Map<String, dynamic>>()
        .map(_mapPersonToUser)
        .toList();
  }

  /// Método específico para cargar usuarios para notificaciones
  /// Solo trae id, name y surname para ser ultra liviano
  Future<List<User>> getUsersForNotifications() async {
    final result = await _query(
      QueryOptions(
        document: gql(_getAllPersonsForNotificationsQuery()),
        variables: {'page': 0, 'size': 100},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final content =
        (result.data?['getAllPersons']?['content'] as List<dynamic>?) ??
        const [];

    return content
        .whereType<Map<String, dynamic>>()
        .map(_mapPersonToUser)
        .toList();
  }

  @override
  Future<int> getTotalUsers({
    String? role,
    String? searchQuery,
    String? statusCurrentDue,
  }) async {
    final filters = _buildFilters(
      searchQuery: searchQuery,
      role: role,
      statusCurrentDue: statusCurrentDue,
    );

    final result = await _query(
      QueryOptions(
        document: gql(_getAllPersonsQuery()),
        variables: {'page': 0, 'size': 1, ...filters},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return (result.data?['getAllPersons']?['totalElements'] as int?) ?? 0;
  }

  @override
  Future<User?> getUserById(String id) async {
    final result = await _query(
      QueryOptions(
        document: gql(_getPersonByIdQuery()),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['getPersonById'] as Map<String, dynamic>?;
    if (data == null) return null;
    return _mapPersonToUser(data);
  }

  @override
  Future<User> createUser(User user) async {
    final input = _mapUserToCreateInput(user);
    final result = await _mutate(
      MutationOptions(
        document: gql(_createPersonMutation()),
        variables: {'input': input},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['createPerson'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Respuesta inválida de createPerson');
    }
    return _mapPersonToUser(data);
  }

  @override
  Future<User> updateUser(User user) async {
    final id = user.id;
    if (id == null || id.isEmpty) {
      throw Exception('No se puede actualizar un usuario sin id');
    }

    final input = _mapUserToUpdateInput(user);
    print('📤 Update input: $input');

    final result = await _mutate(
      MutationOptions(
        document: gql(_updatePersonMutation()),
        variables: {'id': id, 'input': input},
      ),
    );

    print('📥 Update result hasException: ${result.hasException}');
    if (result.hasException) {
      print('❌ Update exception: ${result.exception.toString()}');
      throw Exception(result.exception.toString());
    }

    print('📦 Update result data: ${result.data}');
    final data = result.data?['updatePerson'] as Map<String, dynamic>?;
    if (data == null) {
      print('⚠️ updatePerson data is null');
      throw Exception('Respuesta inválida de updatePerson');
    }
    print('✅ Update successful, mapping to User');
    return _mapPersonToUser(data);
  }

  Future<void> updatePerson(String personId, Map<String, dynamic> input) async {
    final result = await _mutate(
      MutationOptions(
        document: gql(_updatePersonMutation()),
        variables: {'id': personId, 'input': input},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    // Primero obtener el usuario para determinar su rol
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('Usuario no encontrado');
    }

    // Determinar qué mutation usar según el rol principal
    String mutation;
    if (user.tipos.contains(UserType.profesor)) {
      mutation = _deleteProfessorMutation;
    } else {
      // Por defecto usar deletePlayer (jugadores y admins)
      mutation = _deletePlayerMutation;
    }

    final result = await _mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
  }

  User _mapPersonToUser(Map<String, dynamic> person) {
    // Query minimal: NO trae gender, birthDate, email, phone, player, professor
    // Query full: trae TODO
    final gender = (person['gender'] as String?) ?? 'OTHER';
    final parsedGender = switch (gender) {
      'MALE' => Gender.masculino,
      'FEMALE' => Gender.femenino,
      _ => Gender.otro,
    };

    final rolesRaw = person['roles'];
    final roles = <String>[];
    if (rolesRaw is List) {
      roles.addAll(rolesRaw.whereType<String>());
    } else if (rolesRaw is String) {
      roles.add(rolesRaw);
    }

    final tipos = <UserType>{};
    for (final r in roles) {
      switch (r) {
        case 'PLAYER':
          tipos.add(UserType.jugador);
          break;
        case 'PROFESSOR':
          tipos.add(UserType.profesor);
          break;
        case 'ADMIN':
        case 'ADMINISTRATOR':
          tipos.add(UserType.administrador);
          break;
      }
    }

    // Solo procesamos player si existe en la respuesta (query full)
    final player = person['player'] as Map<String, dynamic>?;
    final jerseyNumber = player?['jerseyNumber'];
    final leagueId = player?['leagueId'];
    final teams = (player?['teams'] as List<dynamic>?) ?? const [];

    final equipo = teams.isNotEmpty
        ? ((teams.first as Map<String, dynamic>)['abbreviation'] as String? ??
              '')
        : '';

    final equipos = teams
        .map((t) {
          final teamMap = t as Map<String, dynamic>;
          return TeamInfo(
            id: teamMap['id'] as String? ?? '',
            name: teamMap['name'] as String? ?? '',
            abbreviation: teamMap['abbreviation'] as String? ?? '',
            isCompetitive: teamMap['isCompetitive'] as bool? ?? false,
          );
        })
        .where((team) => team.id.isNotEmpty)
        .toList();

    final birthDate = person['birthDate'] as String?;
    final parsedBirthDate = birthDate != null && birthDate.isNotEmpty
        ? DateTime.tryParse(birthDate)
        : null;

    final professor = person['professor'] as Map<String, dynamic>?;

    // Estado de cuota: obtener desde currentDue del backend
    EstadoCuota estadoCuota = EstadoCuota.alDia;
    CurrentDue? currentDue;
    if (player != null) {
      final currentDueData = player['currentDue'] as Map<String, dynamic>?;
      if (currentDueData != null) {
        print('🔍 currentDueData: $currentDueData');
        try {
          currentDue = CurrentDue.fromJson(currentDueData);
          print('✅ currentDue parsed: state=${currentDue.state}');
          estadoCuota = EstadoCuotaExtension.fromDueState(currentDue.state);
          print('✅ estadoCuota mapped: $estadoCuota');
        } catch (e) {
          print('❌ Error parsing currentDue: $e');
          estadoCuota = EstadoCuota.alDia;
        }
      }
    }

    return User(
      id: person['id'] as String?,
      playerId: player?['id'] as String?,
      professorId: professor?['id'] as String?,
      dni: (person['dni'] as String?) ?? '',
      nombre: (person['name'] as String?) ?? '',
      apellido: (person['surname'] as String?) ?? '',
      fechaNacimiento: parsedBirthDate ?? DateTime(2000, 1, 1),
      genero: parsedGender,
      email: (person['email'] as String?) ?? '',
      telefono: (person['phone'] as String?) ?? '',
      numeroCamiseta: jerseyNumber?.toString(),
      numeroAfiliado: leagueId?.toString(),
      equipo: equipo,
      equipos: equipos,
      tipos: tipos,
      estadoCuota: estadoCuota,
      currentDue: currentDue,
    );
  }

  Map<String, dynamic> _mapUserToCreateInput(User user) {
    if (user.nombre.isEmpty) {
      throw Exception('El nombre es obligatorio');
    }
    if (user.apellido.isEmpty) {
      throw Exception('El apellido es obligatorio');
    }
    if (user.dni.isEmpty) {
      throw Exception('El DNI es obligatorio');
    }
    if (user.email.isEmpty) {
      throw Exception('El email es obligatorio');
    }

    final input = <String, dynamic>{
      'name': user.nombre,
      'surname': user.apellido,
      'dni': user.dni,
      'email': user.email,
      'roles': _mapRolesToApi(user.tipos),
    };

    if (user.telefono.isNotEmpty) {
      input['phone'] = user.telefono;
    }

    // Siempre incluir gender (requerido por el backend)
    input['gender'] = _mapGenderToApi(user.genero);

    final birthDate = _formatBirthDate(user.fechaNacimiento);
    if (birthDate.isNotEmpty) {
      input['birthDate'] = birthDate;
    }

    // Si el usuario es jugador, incluir jerseyNumber y leagueId
    if (user.tipos.contains(UserType.jugador)) {
      final jersey = int.tryParse(user.numeroCamiseta ?? '');
      input['jerseyNumber'] = jersey ?? 0;

      final league = int.tryParse(user.numeroAfiliado ?? '');
      input['leagueId'] = league ?? 0;
    }

    return input;
  }

  Map<String, dynamic> _mapUserToUpdateInput(User user) {
    if (user.nombre.isEmpty) {
      throw Exception('El nombre es obligatorio');
    }
    if (user.apellido.isEmpty) {
      throw Exception('El apellido es obligatorio');
    }
    if (user.dni.isEmpty) {
      throw Exception('El DNI es obligatorio');
    }
    if (user.email.isEmpty) {
      throw Exception('El email es obligatorio');
    }

    final input = <String, dynamic>{
      'name': user.nombre,
      'surname': user.apellido,
      'dni': user.dni,
      'email': user.email,
      'roles': _mapRolesToApi(user.tipos),
    };

    if (user.telefono.isNotEmpty) {
      input['phone'] = user.telefono;
    }

    // Siempre incluir gender (requerido por el backend)
    input['gender'] = _mapGenderToApi(user.genero);

    final birthDate = _formatBirthDate(user.fechaNacimiento);
    if (birthDate.isNotEmpty) {
      input['birthDate'] = birthDate;
    }

    // Si el usuario es jugador, incluir jerseyNumber y leagueId
    if (user.tipos.contains(UserType.jugador)) {
      final jersey = int.tryParse(user.numeroCamiseta ?? '');
      input['jerseyNumber'] = jersey ?? 0;

      final league = int.tryParse(user.numeroAfiliado ?? '');
      input['leagueId'] = league ?? 0;
    }

    return input;
  }

  String _formatBirthDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _mapGenderToApi(Gender gender) {
    switch (gender) {
      case Gender.masculino:
        return 'MALE';
      case Gender.femenino:
        return 'FEMALE';
      case Gender.otro:
        return 'OTHER';
    }
  }

  List<String> _mapRolesToApi(Set<UserType> tipos) {
    final roles = <String>{};
    if (tipos.contains(UserType.administrador)) roles.add('ADMIN');
    if (tipos.contains(UserType.profesor)) roles.add('PROFESSOR');
    if (tipos.contains(UserType.jugador) || roles.isEmpty) roles.add('PLAYER');
    return roles.toList();
  }

  String _getAllAssistanceQuery() => '''
    query GetAllAssistance(\$playerId: ID!, \$startTimeFrom: String, \$endTimeTo: String, \$page: Int!, \$size: Int!) {
      getAllAssistance(
        filters: {playerId: \$playerId, startTimeFrom: \$startTimeFrom, endTimeTo: \$endTimeTo}
        page: \$page
        size: \$size
      ) {
        content {
          id
          date
          assistance
          session {
            startTime
            endTime
          }
        }
        hasNext
        hasPrevious
        pageNumber
        pageSize
        totalElements
        totalPages
      }
    }
  ''';

  String _getAssistanceStatsByPlayerIdQuery() => '''
    query GetAssistanceStatsByPlayerId(\$id: ID!) {
      getAssistanceStatsByPlayerId(id: \$id) {
        assisted
        notAssisted
        assistedPercentage
      }
    }
  ''';

  @override
  Future<AssistancePage> getAllAssistance({
    required String playerId,
    String? startTimeFrom,
    String? endTimeTo,
    required int page,
    required int size,
  }) async {
    try {
      final result = await _query(
        QueryOptions(
          document: gql(_getAllAssistanceQuery()),
          variables: {
            'playerId': playerId,
            'startTimeFrom': startTimeFrom ?? '',
            'endTimeTo': endTimeTo ?? '',
            'page': page,
            'size': size,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(
          'Error al cargar asistencias: ${result.exception.toString()}',
        );
      }

      final data = result.data?['getAllAssistance'];
      if (data == null) {
        throw Exception('No se recibieron datos de asistencias');
      }

      return AssistancePage.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AssistanceStats> getAssistanceStatsByPlayerId(String playerId) async {
    try {
      final result = await _query(
        QueryOptions(
          document: gql(_getAssistanceStatsByPlayerIdQuery()),
          variables: {'id': playerId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(
          'Error al cargar estadísticas de asistencia: ${result.exception.toString()}',
        );
      }

      final data = result.data?['getAssistanceStatsByPlayerId'];
      if (data == null) {
        throw Exception('No se recibieron datos de estadísticas');
      }

      return AssistanceStats.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
