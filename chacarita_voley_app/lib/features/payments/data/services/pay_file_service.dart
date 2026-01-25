import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayFileService {
  static const String baseUrl =
      'https://chaca-jjsnmt6wj7u3.lafuah.com/api/pays';

  /// Sube un comprobante PDF para un pago específico
  ///
  /// [payId] - ID del pago
  /// [file] - Archivo PDF a subir
  ///
  /// Retorna un Map con 'fileName' y 'fileUrl'
  Future<Map<String, String>> uploadReceipt(String payId, File file) async {
    try {
      final uri = Uri.parse('$baseUrl/$payId/receipt');

      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      // Enviar la petición
      var streamedResponse = await request.send();

      // Convertir la respuesta a String
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parsear la respuesta JSON
        var jsonResponse = json.decode(response.body);

        return {
          'fileName': jsonResponse['fileName'] as String,
          'fileUrl': jsonResponse['fileUrl'] as String,
        };
      } else {
        throw Exception(
          'Error al subir archivo: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de red al subir archivo: $e');
    }
  }

  /// Elimina el comprobante de un pago
  Future<void> deleteReceipt(String payId) async {
    try {
      final uri = Uri.parse('$baseUrl/$payId/receipt');

      var response = await http.delete(uri);

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar archivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar archivo: $e');
    }
  }

  /// Obtiene la URL del comprobante (para visualizarlo)
  String getReceiptUrl(String payId) {
    return '$baseUrl/$payId/receipt';
  }
}
