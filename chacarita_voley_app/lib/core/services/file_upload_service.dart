import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import '../environment.dart';
import '../network/graphql_client_factory.dart';

class FileUploadService {
  static const bool _mockUpload = false;
  static const List<String> _allowedExtensions = ['pdf', 'jpeg', 'jpg', 'png'];

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _notificationsInitialized = false;

  static Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) async {
        // Abrir el archivo cuando se toca la notificación
        if (details.payload != null) {
          final file = File(details.payload!);
          if (await file.exists()) {
            await OpenFile.open(details.payload!);
          }
        }
      },
    );

    _notificationsInitialized = true;
  }

  /// Selecciona una imagen desde la cámara o galería
  static Future<File?> pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Selecciona un archivo (PDF, imagen, etc.)
  static Future<File?> pickFile({List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        return File(path);
      }
    }
    return null;
  }

  /// Sube un comprobante de pago al backend
  /// Endpoint: POST /api/pays/{paymentId}/receipt
  /// Retorna: {fileName: "receipts/1/uuid.pdf", fileUrl: "https://..."}
  static Future<Map<String, String>> uploadPaymentReceipt({
    required String paymentId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;

      if (_mockUpload) {
        await Future.delayed(const Duration(seconds: 1));
        return {'fileUrl': 'mock://uploads/$fileName', 'fileName': fileName};
      }

      final url = Uri.parse(
        '${Environment.restBaseUrl}/api/pays/$paymentId/receipt',
      );
      final request = http.MultipartRequest('POST', url);

      final token = GraphQLClientFactory.token;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return {
          'fileUrl': jsonData['fileUrl'] as String,
          'fileName': jsonData['fileName'] as String,
        };
      } else {
        throw Exception(
          'Error al subir comprobante: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al subir comprobante: $e');
    }
  }

  /// Descarga el comprobante de pago desde el backend
  /// Endpoint: GET /api/pays/{paymentId}/receipt
  /// Retorna la URL del endpoint REST que sirve el PDF directamente
  static String getPaymentReceiptUrl({required String paymentId}) {
    return '${Environment.restBaseUrl}/api/pays/$paymentId/receipt';
  }

  /// Descarga el comprobante y muestra notificación del sistema
  /// Guarda el archivo en el directorio de descargas y muestra notificación
  static Future<File> downloadPaymentReceiptWithNotification({
    required String paymentId,
    required String fileName,
  }) async {
    await _initNotifications();

    try {
      final url = Uri.parse(getPaymentReceiptUrl(paymentId: paymentId));
      final token = GraphQLClientFactory.token;
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      // Descargar el archivo
      final response = await http.get(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception(
          'Error al descargar: ${response.statusCode} - ${response.body}',
        );
      }

      // Guardar en directorio de la app (visible para el usuario)
      Directory downloadsDir;

      if (Platform.isAndroid) {
        // Android: usar directorio externo de la app
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          downloadsDir = Directory('${externalDir.path}/Downloads');
        } else {
          // Fallback si no hay almacenamiento externo
          final appDir = await getApplicationDocumentsDirectory();
          downloadsDir = Directory('${appDir.path}/downloads');
        }
      } else {
        // Otras plataformas
        final directory = await getApplicationDocumentsDirectory();
        downloadsDir = Directory('${directory.path}/downloads');
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      // Extraer solo el nombre del archivo sin subdirectorios (fileName puede venir como "receipts/102/archivo.pdf")
      final actualFileName = fileName.split('/').last;
      final filePath = '${downloadsDir.path}/$actualFileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Mostrar notificación de éxito
      const androidDetails = AndroidNotificationDetails(
        'downloads',
        'Descargas',
        channelDescription: 'Notificaciones de descargas completadas',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        paymentId.hashCode,
        'Descarga completada',
        'Comprobante: $actualFileName',
        notificationDetails,
        payload: filePath,
      );

      return file;
    } catch (e) {
      throw Exception('Error al descargar comprobante: $e');
    }
  }

  /// Actualiza el comprobante de pago
  /// Endpoint: PUT /api/pays/{paymentId}/receipt
  /// Retorna: {fileName: "receipts/102/uuid.pdf", fileUrl: "https://..."}
  static Future<Map<String, String>> updatePaymentReceipt({
    required String paymentId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;

      if (_mockUpload) {
        await Future.delayed(const Duration(seconds: 1));
        return {'fileUrl': 'mock://uploads/$fileName', 'fileName': fileName};
      }

      final url = Uri.parse(
        '${Environment.restBaseUrl}/api/pays/$paymentId/receipt',
      );
      final request = http.MultipartRequest('PUT', url);

      final token = GraphQLClientFactory.token;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return {
          'fileUrl': jsonData['fileUrl'] as String,
          'fileName': jsonData['fileName'] as String,
        };
      } else {
        throw Exception(
          'Error al actualizar comprobante: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al actualizar comprobante: $e');
    }
  }

  /// Selecciona y sube un comprobante de pago (PDF, JPEG, PNG)
  static Future<Map<String, String>?> pickAndUploadPaymentReceipt({
    required String paymentId,
  }) async {
    final file = await pickFile(allowedExtensions: _allowedExtensions);
    if (file != null) {
      return await uploadPaymentReceipt(paymentId: paymentId, file: file);
    }
    return null;
  }

  /// Selecciona imagen y la sube como comprobante de pago
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
