import 'package:chacarita_voley_app/core/services/firebase_messaging_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql/ast.dart' as gql;
import 'package:gql_exec/gql_exec.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingLink extends Link {
  Request? lastRequest;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    lastRequest = request;
    return Stream.value(
      Response(
        data: {'registerDevice': true},
        response: const {
          'data': {'registerDevice': true},
        },
      ),
    );
  }
}

void main() {
  group('FirebaseMessagingService.buildRegisterDeviceInput', () {
    test('uses fcm token and platform', () {
      final input = FirebaseMessagingService.buildRegisterDeviceInput(
        'fcm-123',
        NotificationPlatform.ANDROID,
      );

      expect(input['fcmToken'], 'fcm-123');
      expect(input['platform'], 'ANDROID');
    });
  });

  group('FirebaseMessagingService.registerStoredTokenInBackend', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('sends stored token to backend', () async {
      SharedPreferences.setMockInitialValues({'fcm_token': 'fcm-123'});

      final link = _RecordingLink();
      final client = GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      );

      await FirebaseMessagingService().registerStoredTokenInBackend(
        clientOverride: client,
      );

      final variables = link.lastRequest?.variables ?? {};
      final input = variables['input'] as Map<String, dynamic>;
      expect(input['fcmToken'], 'fcm-123');
      expect(input['platform'], 'ANDROID');
    });
  });

  group('FirebaseMessagingService.registerDeviceWithToken', () {
    test('sends token and platform to backend', () async {
      final link = _RecordingLink();
      final client = GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      );

      await FirebaseMessagingService.registerDeviceWithToken(
        token: 'fcm-999',
        platform: NotificationPlatform.ANDROID,
        client: client,
      );

      final variables = link.lastRequest?.variables ?? {};
      final input = variables['input'] as Map<String, dynamic>;
      expect(input['fcmToken'], 'fcm-999');
      expect(input['platform'], 'ANDROID');
    });
  });
}
