import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/graphql_client_factory.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

enum NotificationPlatform { ANDROID, IOS, WEB }

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  static const String _tokenKey = 'fcm_token';

  Future<void> initialize() async {
    await _messaging.setAutoInitEnabled(true);

    await _requestPermission();

    await _getAndRegisterToken();

    _setupTokenRefreshListener();

    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> _getAndRegisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _logToken('📡 FCM token obtenido', token);
        await _saveTokenLocally(token);
        await _registerDeviceInBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
    }
  }

  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      _logToken('🔄 FCM token renovado', newToken);
      _saveTokenLocally(newToken);
      _registerDeviceInBackend(newToken);
    });
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated - user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Foreground message received: ${message.notification?.title}');
      print('Data: ${message.data}');
    }

    // Aquí podés mostrar un dialog o snackbar personalizado
    // O dejar que el sistema muestre la notificación automáticamente
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Message opened app: ${message.data}');
    }

    // Navegar según el tipo de notificación
    final type = message.data['type'];
    switch (type) {
      case 'team':
        // Navigator.push(context, '/teams/${message.data['teamId']}');
        break;
      case 'training':
        // Navigator.push(context, '/trainings/${message.data['trainingId']}');
        break;
      default:
        // Abrir notificaciones generales
        break;
    }
  }

  Future<RemoteMessage?> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }

  Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (kDebugMode) {
      print('FCM Token saved locally: $token');
    }
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static const String _registerDeviceMutation = r'''
      mutation RegisterDevice($input: RegisterDeviceInput!) {
        registerDevice(input: $input)
      }
    ''';

  Future<void> _registerDeviceInBackend(
    String token, {
    GraphQLClient? clientOverride,
  }) async {
    final platform = _getCurrentPlatform();

    try {
      final client = clientOverride ?? GraphQLClientFactory.client;
      if (kDebugMode) {
        debugPrint(
          '📤 RegisterDevice input: ${buildRegisterDeviceInput(_maskToken(token), platform)}',
        );
      }
      final result = await registerDeviceWithToken(
        token: token,
        platform: platform,
        client: client,
      );
      if (kDebugMode) {
        debugPrint('✅ RegisterDevice response: ${result.data?['registerDevice']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception registering device: $e');
      }
    }
  }

  NotificationPlatform _getCurrentPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return NotificationPlatform.ANDROID;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return NotificationPlatform.IOS;
    } else {
      return NotificationPlatform.WEB;
    }
  }

  Future<void> registerStoredTokenInBackend({
    GraphQLClient? clientOverride,
  }) async {
    final token = await getStoredToken();
    if (token == null || token.isEmpty) {
      return;
    }
    await _registerDeviceInBackend(token, clientOverride: clientOverride);
  }

  Future<void> registerDeviceForLogin({
    String? tokenOverride,
    GraphQLClient? clientOverride,
  }) async {
    var token = tokenOverride ?? await getStoredToken();
    if (token == null || token.isEmpty) {
      token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ RegisterDevice skipped: no FCM token');
        }
        return;
      }
      _logToken('📡 FCM token obtenido en login', token);
      await _saveTokenLocally(token);
    }

    await _registerDeviceInBackend(token, clientOverride: clientOverride);
  }

  static Future<QueryResult> registerDeviceWithToken({
    required String token,
    required NotificationPlatform platform,
    required GraphQLClient client,
  }) {
    return client.mutate(
      MutationOptions(
        document: gql(_registerDeviceMutation),
        variables: {'input': buildRegisterDeviceInput(token, platform)},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
  }

  static Map<String, dynamic> buildRegisterDeviceInput(
    String token,
    NotificationPlatform platform,
  ) {
    return {'fcmToken': token, 'platform': platform.name};
  }

  String _maskToken(String token) {
    if (token.length <= 8) return '***';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  void _logToken(String label, String token) {
    if (kDebugMode) {
      debugPrint('$label: ${_maskToken(token)}');
    }
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
