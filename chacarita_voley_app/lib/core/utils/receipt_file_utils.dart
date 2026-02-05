class ReceiptFileUtils {
  static bool isAllowedExtension(String fileName) {
    final parts = fileName.toLowerCase().split('.');
    if (parts.length < 2) return false;
    final extension = parts.last;
    return extension == 'png' ||
        extension == 'jpeg' ||
        extension == 'jpg' ||
        extension == 'pdf';
  }
}
