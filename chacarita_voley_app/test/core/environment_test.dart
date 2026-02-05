import 'package:chacarita_voley_app/core/environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Environment', () {
    test('normalizeBaseUrl adds https when missing', () {
      expect(
        Environment.normalizeBaseUrl('example.com/graphql'),
        'https://example.com/graphql',
      );
    });

    test('normalizeBaseUrl removes trailing slash', () {
      expect(
        Environment.normalizeBaseUrl('https://example.com/graphql/'),
        'https://example.com/graphql',
      );
    });

    test('restBaseUrl strips graphql suffix', () {
      expect(Environment.restBaseUrl.endsWith('/graphql'), isFalse);
    });
  });
}
