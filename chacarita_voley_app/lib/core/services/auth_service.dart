import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../environment.dart';
import '../network/graphql_client_factory.dart';
import '../errors/backend_error_mapper.dart';
import 'snackbar_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRolesKey = 'user_roles';
  static const String _rememberMeKey = 'remember_me';
  static const String _tokenExpiresAtKey = 'token_expires_at';

  // Lock para evitar múltiples refresh simultáneos
  Future<AuthResponse?>? _refreshInFlight;

  /// Login con email y password
  /// Por ahora en modo desarrollo: permite entrar aunque falle
  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final restBaseUrl = Environment.restBaseUrl;
      final url = Uri.parse('$restBaseUrl/api/auth/login');

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

      // Manejar redirecciones
      if (response.statusCode == 301 || response.statusCode == 302) {
        final location = response.headers['location'];
        if (location != null) {
          // Seguir la redirección manualmente
          final redirectUrl = Uri.parse(location);
          final redirectResponse = await http.post(
            redirectUrl,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
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
            return authResponse;
          } else {
            _showBackendError(
              redirectResponse.statusCode,
              redirectResponse.body,
            );
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
          expiresIn: authResponse.expiresIn,
        );

        // Guardar preferencia de recordarme
        await _saveRememberMe(rememberMe);
        return authResponse;
      } else {
        _showBackendError(response.statusCode, response.body);
        print('❌ Login falló: ${response.statusCode}');
        final errorBody = response.body;
        throw Exception('Error de autenticación: $errorBody');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Solicita reseteo de contraseña enviando email
  Future<void> forgotPassword({required String email}) async {
    try {
      final url = Uri.parse(
        '${Environment.restBaseUrl}/api/auth/forgot-password',
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        _showBackendError(response.statusCode, response.body);
        print('❌ Error al enviar email: ${response.statusCode}');
        final errorBody = response.body;
        throw Exception('Error al enviar email de recuperación: $errorBody');
      }
    } catch (e) {
      print('🔥 Error en forgotPassword: $e');
      rethrow;
    }
  }

  /// Obtener información del usuario autenticado
  Future<AuthUser?> getCurrentUser() async {
    try {
      // Usar getValidAccessToken() que maneja renovación proactiva
      final token = await getValidAccessToken();
      if (token == null) {
        print('❌ No hay token válido disponible');
        return null;
      }

      final restBaseUrl = Environment.restBaseUrl;
      final url = Uri.parse('$restBaseUrl/api/auth/me');

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

      // Manejar redirecciones
      if (response.statusCode == 301 || response.statusCode == 302) {
        final location = response.headers['location'];
        if (location != null) {
          final redirectUrl = Uri.parse(location);
          final redirectResponse = await http.get(
            redirectUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (redirectResponse.statusCode == 200) {
            final data =
                json.decode(redirectResponse.body) as Map<String, dynamic>;
            final user = AuthUser.fromJson(data);
            await _saveUserInfo(user);
            return user;
          } else {
            _showBackendError(
              redirectResponse.statusCode,
              redirectResponse.body,
            );
            print(
              '❌ Error al obtener usuario después de redirección: ${redirectResponse.statusCode}',
            );
            return null;
          }
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final user = AuthUser.fromJson(data);

        await _saveUserInfo(user);
        return user;
      } else {
        _showBackendError(response.statusCode, response.body);
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

      final restBaseUrl = Environment.restBaseUrl;
      final url = Uri.parse('$restBaseUrl/api/auth/change-password');

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

      // 200 OK o 204 No Content son exitosos
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        _showBackendError(response.statusCode, response.body);
        print('❌ Contraseña actual incorrecta');
        throw Exception('La contraseña actual es incorrecta');
      } else {
        _showBackendError(response.statusCode, response.body);
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
    int? expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_emailKey, email);

    // Guardar timestamp de expiración
    if (expiresIn != null) {
      final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
      await prefs.setInt(_tokenExpiresAtKey, expiresAt.millisecondsSinceEpoch);
    }

    // Actualizar el token en GraphQLClient
    GraphQLClientFactory.updateToken(accessToken);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Obtiene un access token válido, renovándolo proactivamente si está por expirar
  Future<String?> getValidAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiresAtMs = prefs.getInt(_tokenExpiresAtKey);

    if (token == null) {
      print('❌ No hay token disponible');
      return null;
    }

    // Si no tenemos timestamp de expiración, asumir que es válido
    // (para retrocompatibilidad con tokens guardados sin expiresAt)
    if (expiresAtMs == null) {
      return token;
    }

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
    final now = DateTime.now();
    final timeUntilExpiry = expiresAt.difference(now);

    // Margen de seguridad: renovar si quedan menos de 60 segundos
    if (timeUntilExpiry.inSeconds < 60) {
      try {
        final refreshed = await refreshToken();
        if (refreshed != null) {
          return refreshed.accessToken;
        } else {
          print('❌ No se pudo renovar el token');
          return null;
        }
      } catch (e) {
        print('🔥 Error al renovar token proactivamente: $e');
        return null;
      }
    }

    return token;
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
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

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  Future<bool> shouldRememberSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  void _showBackendError(int statusCode, String body) {
    final message = BackendErrorMapper.fromHttpResponse(statusCode, body);
    SnackbarService.showError(message);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        final restBaseUrl = Environment.restBaseUrl;
        final url = Uri.parse('$restBaseUrl/api/auth/logout');

        try {
          final response = await http
              .post(
                url,
                headers: {'Content-Type': 'application/json'},
                body: json.encode({'refreshToken': refreshToken}),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  print('⏱️ Timeout en logout');
                  throw Exception('Timeout al hacer logout');
                },
              );

          print('📡 Logout status code: ${response.statusCode}');

          if (response.statusCode == 200 || response.statusCode == 204) {
          } else {
            _showBackendError(response.statusCode, response.body);
            print('⚠️ Logout en backend fallo: ${response.statusCode}');
          }
        } catch (e) {
          print('❌ Error al llamar logout endpoint: $e');
          // Continuar con limpieza local aunque falle el backend
        }
      }
    } catch (e) {
      print('⚠️ Error obteniendo refresh token: $e');
    }

    // Limpiar datos locales siempre
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRolesKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_tokenExpiresAtKey);

    // Limpiar el token en GraphQLClient
    GraphQLClientFactory.updateToken(null);
  }

  /// Renovar el access token usando el refresh token
  Future<AuthResponse?> refreshToken() async {
    // Si ya hay un refresh en progreso, esperar a que termine
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    // Iniciar nuevo refresh y guardarlo para que otros esperen
    _refreshInFlight = _doRefreshToken().whenComplete(() {
      _refreshInFlight = null;
    });

    return _refreshInFlight!;
  }

  /// Lógica interna de refresh (llamada solo por refreshToken)
  Future<AuthResponse?> _doRefreshToken() async {
    try {
      final currentRefreshToken = await getRefreshToken();

      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        print('❌ No hay refresh token disponible');
        return null;
      }

      final restBaseUrl = Environment.restBaseUrl;
      final url = Uri.parse('$restBaseUrl/api/auth/refresh');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $currentRefreshToken',
            },
            body: json.encode({'refreshToken': currentRefreshToken}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Timeout en refresh token');
              throw Exception('Timeout al renovar token');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        final authResponse = AuthResponse(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          expiresIn: data['expiresIn'] as int,
          tokenType: data['tokenType'] as String? ?? 'Bearer',
        );

        final email = await getEmail();
        if (email != null) {
          await _saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            email: email,
            expiresIn: authResponse.expiresIn,
          );
        }
        return authResponse;
      } else {
        _showBackendError(response.statusCode, response.body);
        print('❌ Error al renovar token: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        // Si el refresh token es inválido, limpiar sesión
        if (response.statusCode == 401) {
          print('🚨 Refresh token inválido, cerrando sesión');
          await logout();
        }
        return null;
      }
    } catch (e) {
      print('🔥 Error en refresh token: $e');
      return null;
    }
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