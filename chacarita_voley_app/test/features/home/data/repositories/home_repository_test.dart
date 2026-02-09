import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/home/data/repositories/home_repository.dart';

void main() {
  test('formatDeliveryDateTime returns ISO local date-time', () {
    final date = DateTime(2026, 2, 9, 7, 5, 3);
    final formatted = HomeRepository.formatDeliveryDateTime(date);

    expect(formatted, '2026-02-09T07:05:03');
  });

  test('player deliveries query limits to 3 items', () {
    final repository = HomeRepository();
    final query = repository.buildPlayerDeliveriesQuery(
      personId: '1',
      sentFrom: '2026-02-01T00:00:00',
      sentTo: '2026-02-08T23:59:59',
    );

    expect(query, contains('size: 3'));
  });
}
