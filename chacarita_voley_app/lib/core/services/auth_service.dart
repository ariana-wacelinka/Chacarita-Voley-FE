import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../environment.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _emailKey = 'user_email';

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

        // MODO DESARROLLO: Permitir acceso aunque falle
        print('⚠️ MODO DESARROLLO: Permitiendo acceso sin autenticación real');

        final mockResponse = AuthResponse(
          accessToken: 'mock-token-dev',
          refreshToken: 'mock-refresh-dev',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );

        await _saveTokens(
          accessToken: mockResponse.accessToken,
          refreshToken: mockResponse.refreshToken,
          email: email,
        );

        return mockResponse;
      }
    } catch (e) {
      print('🔥 Error en login: $e');

      // MODO DESARROLLO: Permitir acceso aunque falle
      print('⚠️ MODO DESARROLLO: Permitiendo acceso sin autenticación real');

      final mockResponse = AuthResponse(
        accessToken: 'mock-token-dev',
        refreshToken: 'mock-refresh-dev',
        expiresIn: 3600,
        tokenType: 'Bearer',
      );

      await _saveTokens(
        accessToken: mockResponse.accessToken,
        refreshToken: mockResponse.refreshToken,
        email: email,
      );

      return mockResponse;
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

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_emailKey);
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
