import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../environment.dart';
import 'auth_service.dart';
import 'file_upload_types.dart';

class FileUploadService {
  static const bool _mockUpload = false;
  static const List<String> _allowedExtensions = ['pdf', 'jpeg', 'png'];
  static const List<String> _pickerExtensions = ['pdf', 'jpeg', 'jpg', 'png'];

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
    return SelectedFile(name: pickedFile.name, bytes: bytes);
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
    final bytes = file.bytes;
    if (bytes == null) return null;

    return SelectedFile(name: file.name, bytes: bytes);
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

    if (file.bytes == null) {
      throw Exception('Archivo inválido');
    }

    return SelectedFile(name: name, bytes: file.bytes);
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
    final url = Uri.parse(getPaymentReceiptUrl(paymentId: paymentId));
    await launchUrl(url, mode: LaunchMode.externalApplication);
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
