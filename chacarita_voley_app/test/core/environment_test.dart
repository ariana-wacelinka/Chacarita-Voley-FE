import 'package:chacarita_voley_app/core/environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Environment', () {
    test('normalizeBaseUrl adds https when missing', () {
      expect(
        Environment.normalizeBaseUrl('example.com/graphql'),
        'https://example.com',
      );
    });

    test('normalizeBaseUrl removes trailing slash', () {
      expect(
        Environment.normalizeBaseUrl('https://example.com/'),
        'https://example.com',
      );
    });

    test('restBaseUrl strips graphql suffix', () {
      expect(Environment.restBaseUrl.endsWith('/graphql'), isFalse);
    });

    test('graphqlBaseUrl appends graphql suffix', () {
      expect(Environment.graphqlBaseUrl.endsWith('/graphql'), isTrue);
    });
  });
}
