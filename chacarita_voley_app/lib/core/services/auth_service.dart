import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../environment.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRolesKey = 'user_roles';

  /// Login con email y password
  /// Por ahora en modo desarrollo: permite entrar aunque falle
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      // Construir URL REST (sin /graphql)
      final restBaseUrl = Environment.baseUrl.replaceAll('/graphql', '');
      final url = Uri.parse('$restBaseUrl/api/auth/login');

      print('🔐 Intentando login en: $url');
      print('📧 Email: $email');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Timeout en login');
              throw Exception('Timeout al conectar con el servidor');
            },
          );

      print('📡 Status code: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // Manejar redirecciones
      if (response.statusCode == 301 || response.statusCode == 302) {
        final location = response.headers['location'];
        print('🔄 Redirigido a: $location');
        if (location != null) {
          // Seguir la redirección manualmente
          final redirectUrl = Uri.parse(location);
          final redirectResponse = await http.post(
            redirectUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          );
          print(
            '📡 Status code después de redirección: ${redirectResponse.statusCode}',
          );
          print(
            '📦 Response body después de redirección: ${redirectResponse.body}',
          );

          if (redirectResponse.statusCode == 200) {
            final data =
                json.decode(redirectResponse.body) as Map<String, dynamic>;
            final authResponse = AuthResponse(
              accessToken: data['accessToken'] as String,
              refreshToken: data['refreshToken'] as String,
              expiresIn: data['expiresIn'] as int,
              tokenType: data['tokenType'] as String? ?? 'Bearer',
            );
            await _saveTokens(
              accessToken: authResponse.accessToken,
              refreshToken: authResponse.refreshToken,
              email: email,
            );
            print('✅ Login exitoso');
            return authResponse;
          } else {
            print(
              '❌ Login falló después de redirección: ${redirectResponse.statusCode}',
            );
            final errorBody = redirectResponse.body;
            throw Exception('Error de autenticación: $errorBody');
          }
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final authResponse = AuthResponse(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          expiresIn: data['expiresIn'] as int,
          tokenType: data['tokenType'] as String? ?? 'Bearer',
        );

        // Guardar tokens
        await _saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          email: email,
        );

        print('✅ Login exitoso');
        return authResponse;
      } else {
        print('❌ Login falló: ${response.statusCode}');
        final errorBody = response.body;
        throw Exception('Error de autenticación: $errorBody');
      }
    } catch (e) {
      print('🔥 Error en login: $e');
      rethrow;
    }
  }

  /// Obtener información del usuario autenticado
  Future<AuthUser?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        print('❌ No hay token disponible');
        return null;
      }

      final restBaseUrl = Environment.baseUrl.replaceAll('/graphql', '');
      final url = Uri.parse('$restBaseUrl/api/auth/me');

      print('👤 Obteniendo información del usuario: $url');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Timeout al obtener usuario');
              throw Exception('Timeout al obtener información del usuario');
            },
          );

      print('📡 Status code: ${response.statusCode}');
      print('📦 Response body completo: ${response.body}');

      // Manejar redirecciones
      if (response.statusCode == 301 || response.statusCode == 302) {
        final location = response.headers['location'];
        print('🔄 Redirigido a: $location');
        if (location != null) {
          final redirectUrl = Uri.parse(location);
          final redirectResponse = await http.get(
            redirectUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          print(
            '📡 Status code después de redirección: ${redirectResponse.statusCode}',
          );

          if (redirectResponse.statusCode == 200) {
            final data =
                json.decode(redirectResponse.body) as Map<String, dynamic>;
            print('📋 Datos del usuario parseados:');
            print('   - ID: ${data['id']}');
            print('   - Name: ${data['name']}');
            print('   - Surname: ${data['surname']}');
            print('   - DNI: ${data['dni']}');
            print('   - Email: ${data['email']}');
            print('   - Phone: ${data['phone']}');
            print('   - BirthDate: ${data['birthDate']}');
            print('   - Gender: ${data['gender']}');
            print('   - Roles: ${data['roles']}');

            final user = AuthUser.fromJson(data);
            await _saveUserInfo(user);
            print('✅ Usuario obtenido: ${user.name} ${user.surname}');
            print('   - Roles procesados: ${user.roles}');
            print('   - Es admin: ${user.isAdmin}');
            print('   - Es profesor: ${user.isProfesor}');
            print('   - Es jugador: ${user.isJugador}');
            return user;
          } else {
            print(
              '❌ Error al obtener usuario después de redirección: ${redirectResponse.statusCode}',
            );
            return null;
          }
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        print('📋 Datos del usuario parseados:');
        print('   - ID: ${data['id']}');
        print('   - Name: ${data['name']}');
        print('   - Surname: ${data['surname']}');
        print('   - DNI: ${data['dni']}');
        print('   - Email: ${data['email']}');
        print('   - Phone: ${data['phone']}');
        print('   - BirthDate: ${data['birthDate']}');
        print('   - Gender: ${data['gender']}');
        print('   - Roles: ${data['roles']}');

        final user = AuthUser.fromJson(data);

        // Guardar información del usuario
        await _saveUserInfo(user);

        print('✅ Usuario obtenido: ${user.name} ${user.surname}');
        print('   - Roles procesados: ${user.roles}');
        print('   - Es admin: ${user.isAdmin}');
        print('   - Es profesor: ${user.isProfesor}');
        print('   - Es jugador: ${user.isJugador}');
        return user;
      } else {
        print('❌ Error al obtener usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 Error al obtener usuario: $e');
      return null;
    }
  }

  Future<void> _saveUserInfo(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, user.id);
    await prefs.setString(_userNameKey, '${user.name} ${user.surname}');
    await prefs.setString(_userRolesKey, json.encode(user.roles));
  }

  /// Cambiar contraseña del usuario autenticado
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No hay sesión activa');
      }

      final restBaseUrl = Environment.baseUrl.replaceAll('/graphql', '');
      final url = Uri.parse('$restBaseUrl/api/auth/change-password');

      print('🔐 Cambiando contraseña en: $url');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({'newPassword': newPassword}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Timeout en cambio de contraseña');
              throw Exception('Timeout al cambiar contraseña');
            },
          );

      print('📡 Status code: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      // 200 OK o 204 No Content son exitosos
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Contraseña cambiada exitosamente');
        return;
      } else if (response.statusCode == 401) {
        print('❌ Contraseña actual incorrecta');
        throw Exception('La contraseña actual es incorrecta');
      } else {
        print('❌ Error al cambiar contraseña: ${response.statusCode}');
        final errorBody = response.body;
        throw Exception('Error al cambiar contraseña: $errorBody');
      }
    } catch (e) {
      print('🔥 Error en cambio de contraseña: $e');
      rethrow;
    }
  }

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<List<String>?> getUserRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final rolesJson = prefs.getString(_userRolesKey);
    if (rolesJson == null) return null;
    return List<String>.from(json.decode(rolesJson));
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRolesKey);
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });
}

class AuthUser {
  final int id;
  final String name;
  final String surname;
  final String dni;
  final String email;
  final String? phone;
  final DateTime? birthDate;
  final String gender;
  final List<String> roles;

  AuthUser({
    required this.id,
    required this.name,
    required this.surname,
    required this.dni,
    required this.email,
    this.phone,
    this.birthDate,
    required this.gender,
    required this.roles,
  });

  String get fullName => '$name $surname';

  bool get isAdmin => roles.contains('ADMIN');
  bool get isProfesor => roles.contains('PROFESSOR');
  bool get isJugador => roles.contains('PLAYER');

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      surname: json['surname'] as String,
      dni: json['dni'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      gender: json['gender'] as String,
      roles: List<String>.from(json['roles'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'dni': dni,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'roles': roles,
    };
  }
}
