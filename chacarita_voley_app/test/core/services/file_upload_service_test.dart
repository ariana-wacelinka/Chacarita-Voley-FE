import 'package:chacarita_voley_app/core/services/file_upload_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileUploadService', () {
    test('allows jpg, jpeg, png, and pdf', () {
      expect(FileUploadService.isAllowedReceiptExtension('file.jpg'), isTrue);
      expect(FileUploadService.isAllowedReceiptExtension('file.jpeg'), isTrue);
      expect(FileUploadService.isAllowedReceiptExtension('file.png'), isTrue);
      expect(FileUploadService.isAllowedReceiptExtension('file.pdf'), isTrue);
    });

    test('rejects unsupported extension', () {
      expect(FileUploadService.isAllowedReceiptExtension('file.gif'), isFalse);
    });
  });
}
