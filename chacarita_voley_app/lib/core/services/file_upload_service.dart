import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../environment.dart';
import '../network/graphql_client_factory.dart';

class FileUploadService {
  // TODO: Actualizar con el endpoint real cuando esté disponible en el backend
  static const String _uploadEndpoint = '/api/upload';
  static const bool _mockUpload =
      true; // Cambiar a false cuando el backend esté listo

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

  /// Sube un archivo al backend y retorna la URL y nombre del archivo
  static Future<Map<String, String>> uploadFile(File file) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;

      // Modo mock: simular upload exitoso sin llamar al backend
      if (_mockUpload) {
        // Simular delay de red
        await Future.delayed(const Duration(seconds: 1));

        return {'fileUrl': 'mock://uploads/$fileName', 'fileName': fileName};
      }

      // Modo real: subir al backend
      final url = Uri.parse('${Environment.baseUrl}$_uploadEndpoint');
      final request = http.MultipartRequest('POST', url);

      // Agregar token de autorización si existe
      final token = GraphQLClientFactory.token;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Agregar el archivo
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // TODO: Parsear la respuesta JSON real del backend
        // final jsonResponse = json.decode(response.body);
        // return {
        //   'fileUrl': jsonResponse['fileUrl'],
        //   'fileName': jsonResponse['fileName'],
        // };

        return {
          'fileUrl': 'https://ejemplo.com/uploads/$fileName',
          'fileName': fileName,
        };
      } else {
        throw Exception('Error al subir archivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al subir archivo: $e');
    }
  }

  /// Opción combinada: seleccionar y subir archivo
  static Future<Map<String, String>?> pickAndUploadFile({
    List<String>? allowedExtensions,
  }) async {
    final file = await pickFile(allowedExtensions: allowedExtensions);
    if (file != null) {
      return await uploadFile(file);
    }
    return null;
  }

  /// Opción combinada: seleccionar y subir imagen
  static Future<Map<String, String>?> pickAndUploadImage({
    required ImageSource source,
  }) async {
    final file = await pickImage(source: source);
    if (file != null) {
      return await uploadFile(file);
    }
    return null;
  }
}
