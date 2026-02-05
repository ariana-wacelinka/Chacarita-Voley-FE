import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/core/utils/receipt_file_utils.dart';

void main() {
  test('allows supported receipt extensions', () {
    expect(ReceiptFileUtils.isAllowedExtension('pago.png'), isTrue);
    expect(ReceiptFileUtils.isAllowedExtension('pago.jpeg'), isTrue);
    expect(ReceiptFileUtils.isAllowedExtension('pago.jpg'), isTrue);
    expect(ReceiptFileUtils.isAllowedExtension('pago.pdf'), isTrue);
    expect(ReceiptFileUtils.isAllowedExtension('PAGO.PDF'), isTrue);
  });

  test('rejects unsupported or missing extensions', () {
    expect(ReceiptFileUtils.isAllowedExtension('pago.txt'), isFalse);
    expect(ReceiptFileUtils.isAllowedExtension('pago'), isFalse);
    expect(ReceiptFileUtils.isAllowedExtension(''), isFalse);
  });
}
