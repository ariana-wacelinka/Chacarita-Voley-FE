import 'package:chacarita_voley_app/core/utils/date_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatDateDdMmYyyy formats date as dd/MM/yyyy', () {
    final date = DateTime(2026, 2, 8);

    expect(formatDateDdMmYyyy(date), '08/02/2026');
  });
}
