import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../environment.dart';
import '../network/graphql_client_factory.dart';

class FileUploadService {
  static const bool _mockUpload = false;
  static const List<String> _allowedExtensions = ['pdf', 'jpeg', 'jpg', 'png'];

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
        '${Environment.baseUrl}/api/pays/$paymentId/receipt',
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
