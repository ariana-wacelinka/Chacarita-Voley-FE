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

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const String _tokenKey = 'fcm_token';

  Future<void> initialize() async {
    await _firebaseMessaging.setAutoInitEnabled(true);

    await _requestPermission();

    await _getAndRegisterToken();

    _setupTokenRefreshListener();

    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
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
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          debugPrint('📡 FCM token obtenido: ${_maskToken(token)}');
        }
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
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
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
    return await _firebaseMessaging.getInitialMessage();
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

  Future<void> _registerDeviceInBackend(
    String token, {
    GraphQLClient? clientOverride,
  }) async {
    const mutation = r'''
      mutation RegisterDevice($input: RegisterDeviceInput!) {
        registerDevice(input: $input)
      }
    ''';

    final platform = _getCurrentPlatform();

    try {
      final client = clientOverride ?? GraphQLClientFactory.client;
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {'input': buildRegisterDeviceInput(token, platform)},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
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

  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
