import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/domain/policies/booking_list_policy.dart';

import '../../../support/booking_test_data.dart';

void main() {
  group('BookingListPolicy', () {
    final now = DateTime.utc(2026, 7, 10, 12);

    test('groups upcoming active bookings with future slot', () {
      final upcoming = testBookingSummary(
        id: 'upcoming-id',
        slotStartAt: DateTime.utc(2026, 7, 11, 10),
      );
      final past = testBookingSummary(
        id: 'past-id',
        slotStartAt: DateTime.utc(2026, 7, 9, 10),
      );
      final cancelled = testBookingSummary(
        id: 'cancelled-id',
        status: BookingStatus.cancelled,
        slotStartAt: DateTime.utc(2026, 7, 11, 10),
      );

      final grouped = BookingListPolicy.groupBySection(
        [upcoming, past, cancelled],
        now: now,
      );

      expect(grouped[BookingListSection.upcoming], [upcoming]);
      expect(grouped[BookingListSection.pastAndCancelled], [past, cancelled]);
    });

    test('treats active booking without slot as upcoming', () {
      final booking = BookingSummaryDto(
        id: 'no-slot',
        slotId: '11111111-1111-1111-1111-111111111111',
        equipment: Equipment.own,
        status: BookingStatus.active,
        priceTotal: 1200,
        createdAt: DateTime.utc(2026, 7, 10, 9),
      );

      expect(BookingListPolicy.isUpcoming(booking, now), isTrue);
    });
  });
}
