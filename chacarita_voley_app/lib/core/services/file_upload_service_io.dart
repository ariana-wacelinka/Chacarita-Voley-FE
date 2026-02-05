import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../environment.dart';
import 'auth_service.dart';
import 'file_upload_types.dart';

class FileUploadService {
  static const bool _mockUpload = false;
  static const List<String> _allowedExtensions = ['pdf', 'jpeg', 'png'];
  static const List<String> _pickerExtensions = ['pdf', 'jpeg', 'jpg', 'png'];

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _notificationsInitialized = false;

  static Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload != null) {
          final file = File(details.payload!);
          if (await file.exists()) {
            await OpenFile.open(details.payload!);
          }
        }
      },
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    const channel = AndroidNotificationChannel(
      'downloads',
      'Descargas',
      description: 'Notificaciones de descargas completadas',
      importance: Importance.high,
    );
    await androidPlugin?.createNotificationChannel(channel);

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    _notificationsInitialized = true;
  }

  static MediaType _getMediaType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  static Future<SelectedFile?> pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile == null) return null;
    final bytes = await pickedFile.readAsBytes();
    return SelectedFile(
      name: pickedFile.name,
      path: pickedFile.path,
      bytes: bytes,
    );
  }

  static Future<SelectedFile?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final bytes =
        file.bytes ??
        (file.path != null ? File(file.path!).readAsBytesSync() : null);
    if (bytes == null) return null;

    return SelectedFile(name: file.name, path: file.path, bytes: bytes);
  }

  static Future<SelectedFile> _normalizeReceiptFile(SelectedFile file) async {
    final parts = file.name.toLowerCase().split('.');
    if (parts.length < 2) {
      throw Exception('Formato no permitido');
    }
    final extension = parts.last;
    final name = extension == 'jpg'
        ? file.name.replaceAll(RegExp(r'(?i)\.jpg$'), '.jpeg')
        : file.name;

    if (extension != 'jpg' && !_allowedExtensions.contains(extension)) {
      throw Exception('Formato no permitido');
    }

    final bytes =
        file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) {
      throw Exception('Archivo inválido');
    }

    return SelectedFile(name: name, bytes: bytes, path: file.path);
  }

  static Future<Map<String, String>> uploadPaymentReceipt({
    required String paymentId,
    required SelectedFile file,
  }) async {
    try {
      final normalizedFile = await _normalizeReceiptFile(file);
      final fileName = normalizedFile.name;

      if (_mockUpload) {
        await Future.delayed(const Duration(seconds: 1));
        return {'fileUrl': 'mock://uploads/$fileName', 'fileName': fileName};
      }

      final url = Uri.parse(
        '${Environment.restBaseUrl}/api/pays/$paymentId/receipt',
      );
      final request = http.MultipartRequest('POST', url);

      final authService = AuthService();
      final token = await authService.getValidAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final mediaType = _getMediaType(fileName);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          normalizedFile.bytes!,
          filename: fileName,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return {
          'fileUrl': jsonData['fileUrl'] as String,
          'fileName': jsonData['fileName'] as String,
        };
      }

      throw Exception(
        'Error al subir comprobante: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error al subir comprobante: $e');
    }
  }

  static String getPaymentReceiptUrl({required String paymentId}) {
    return '${Environment.restBaseUrl}/api/pays/$paymentId/receipt';
  }

  static Future<void> downloadPaymentReceiptWithNotification({
    required String paymentId,
    required String fileName,
  }) async {
    await _initNotifications();

    final url = Uri.parse(getPaymentReceiptUrl(paymentId: paymentId));
    final authService = AuthService();
    final token = await authService.getValidAccessToken();
    final headers = token != null
        ? {'Authorization': 'Bearer $token'}
        : <String, String>{};

    final response = await http.get(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
        'Error al descargar: ${response.statusCode} - ${response.body}',
      );
    }

    Directory downloadsDir;

    if (Platform.isAndroid) {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        downloadsDir = Directory('${externalDir.path}/Downloads');
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        downloadsDir = Directory('${appDir.path}/downloads');
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      downloadsDir = Directory('${directory.path}/downloads');
    }

    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final actualFileName = fileName.split('/').last;
    final filePath = '${downloadsDir.path}/$actualFileName';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    const androidDetails = AndroidNotificationDetails(
      'downloads',
      'Descargas',
      channelDescription: 'Notificaciones de descargas completadas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      paymentId.hashCode,
      'Descarga completada',
      'Comprobante: $actualFileName',
      notificationDetails,
      payload: filePath,
    );
  }

  static Future<Map<String, String>> updatePaymentReceipt({
    required String paymentId,
    required SelectedFile file,
  }) async {
    try {
      final normalizedFile = await _normalizeReceiptFile(file);
      final fileName = normalizedFile.name;

      if (_mockUpload) {
        await Future.delayed(const Duration(seconds: 1));
        return {'fileUrl': 'mock://uploads/$fileName', 'fileName': fileName};
      }

      final url = Uri.parse(
        '${Environment.restBaseUrl}/api/pays/$paymentId/receipt',
      );

      final request = http.MultipartRequest('PUT', url);

      final authService = AuthService();
      final token = await authService.getValidAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final mediaType = _getMediaType(fileName);
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        normalizedFile.bytes!,
        filename: fileName,
        contentType: mediaType,
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return {
          'fileUrl': jsonData['fileUrl'] as String,
          'fileName': jsonData['fileName'] as String,
        };
      }

      throw Exception(
        'Error al actualizar comprobante: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error al actualizar comprobante: $e');
    }
  }

  static Future<Map<String, String>?> pickAndUploadPaymentReceipt({
    required String paymentId,
  }) async {
    final file = await pickFile(allowedExtensions: _pickerExtensions);
    if (file != null) {
      return await uploadPaymentReceipt(paymentId: paymentId, file: file);
    }
    return null;
  }

  static Future<Map<String, String>?> pickAndUploadPaymentReceiptImage({
    required String paymentId,
    required ImageSource source,
  }) async {
    final file = await pickImage(source: source);
    if (file != null) {
      return await uploadPaymentReceipt(paymentId: paymentId, file: file);
    }
    return null;
  }
}
