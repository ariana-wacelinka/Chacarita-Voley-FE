import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/home/data/repositories/home_repository.dart';

void main() {
  test('formatDeliveryDateTime returns ISO local date-time', () {
    final date = DateTime(2026, 2, 9, 7, 5, 3);
    final formatted = HomeRepository.formatDeliveryDateTime(date);

    expect(formatted, '2026-02-09T07:05:03');
  });
}
