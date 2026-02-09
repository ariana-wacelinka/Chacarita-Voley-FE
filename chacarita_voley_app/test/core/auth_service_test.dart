import 'package:chacarita_voley_app/core/services/auth_service.dart';
import 'package:chacarita_voley_app/core/network/graphql_client_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService.buildRefreshHeaders', () {
    test('includes authorization when access token exists', () {
      final headers = AuthService.buildRefreshHeaders(accessToken: 'token');

      expect(headers['Content-Type'], 'application/json');
      expect(headers['Authorization'], 'Bearer token');
    });

    test('omits authorization when access token missing', () {
      final headers = AuthService.buildRefreshHeaders();

      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });

  group('AuthService.saveTokensForTest', () {
    setUpAll(() {
      GraphQLClientFactory.init(baseUrl: 'http://localhost/graphql');
    });

    test('saves tokens even when email missing', () async {
      SharedPreferences.setMockInitialValues({'user_email': 'old@mail.com'});

      final service = AuthService();
      await service.saveTokensForTest(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );

      expect(await service.getToken(), 'access-1');
      expect(await service.getRefreshToken(), 'refresh-1');
      expect(await service.getEmail(), 'old@mail.com');
    });

    test('overwrites email when provided', () async {
      SharedPreferences.setMockInitialValues({'user_email': 'old@mail.com'});

      final service = AuthService();
      await service.saveTokensForTest(
        accessToken: 'access-2',
        refreshToken: 'refresh-2',
        email: 'new@mail.com',
      );

      expect(await service.getToken(), 'access-2');
      expect(await service.getRefreshToken(), 'refresh-2');
      expect(await service.getEmail(), 'new@mail.com');
    });
  });
}
