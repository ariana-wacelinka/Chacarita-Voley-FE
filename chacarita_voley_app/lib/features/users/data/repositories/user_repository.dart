import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../../core/network/graphql_client_factory.dart';
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
    return GraphQLClientFactory.withFreshClient(run: (c) => c.query(options));
  }

  Future<QueryResult> _mutate(MutationOptions options) {
    final override = _clientOverride;
    if (override != null) return override.mutate(options);
    return GraphQLClientFactory.withFreshClient(run: (c) => c.mutate(options));
  }

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
    admin {
      id
    }
    player {
      id
      leagueId
      jerseyNumber
      teams { id isCompetitive name }
      dues { id }
      assistances { id }
    }
    professor {
      id
      teams { id isCompetitive name }
    }
  ''';

  String _getAllPersonsQuery() =>
      '''
    query GetAllPersons(\$page: Int!, \$size: Int!) {
      getAllPersons(page: \$page, size: \$size, filters: {}) {
        content {
          $_personFields
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

  @override
  Future<List<User>> getUsers() async {
    final result = await _query(
      QueryOptions(
        document: gql(_getAllPersonsQuery()),
        variables: {'page': 0, 'size': 2000},
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
    if (tipos.isEmpty) {
      tipos.add(UserType.jugador);
    }

    final player = person['player'] as Map<String, dynamic>?;
    final jerseyNumber = player?['jerseyNumber'];
    final teams = (player?['teams'] as List<dynamic>?) ?? const [];
    final equipo = teams.isNotEmpty
        ? ((teams.first as Map<String, dynamic>)['name'] as String? ?? '')
        : '';

    final equipos = teams
        .map(
          (t) => TeamInfo(
            id: (t as Map<String, dynamic>)['id'] as String? ?? '',
            name: t['name'] as String? ?? '',
            abbreviation: t['abbreviation'] as String? ?? '',
            isCompetitive: t['isCompetitive'] as bool? ?? false,
          ),
        )
        .toList();

    final birthDate = person['birthDate'] as String?;
    final parsedBirthDate = birthDate != null && birthDate.isNotEmpty
        ? DateTime.tryParse(birthDate)
        : null;

    return User(
      id: person['id'] as String?,
      playerId: player?['id'] as String?,
      dni: (person['dni'] as String?) ?? '',
      nombre: (person['name'] as String?) ?? '',
      apellido: (person['surname'] as String?) ?? '',
      fechaNacimiento: parsedBirthDate ?? DateTime(2000, 1, 1),
      genero: parsedGender,
      email: (person['email'] as String?) ?? '',
      telefono: (person['phone'] as String?) ?? '',
      numeroCamiseta: jerseyNumber?.toString(),
      equipo: equipo,
      equipos: equipos,
      tipos: tipos,
      estadoCuota: EstadoCuota.alDia,
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
      input['leagueId'] = 0; // TODO: obtener del usuario cuando esté disponible
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
}
