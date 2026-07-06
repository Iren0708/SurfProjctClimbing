import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_status_labels.dart';

void main() {
  group('BookingStatusLabels', () {
    final now = DateTime.utc(2026, 7, 10, 12);

    test('active future slot is active', () {
      expect(
        BookingStatusLabels.forBooking(
          status: BookingStatus.active,
          slotStartAt: DateTime.utc(2026, 7, 11, 10),
          now: now,
        ),
        BookingStatusLabels.active,
      );
    });

    test('active past slot is past', () {
      expect(
        BookingStatusLabels.forBooking(
          status: BookingStatus.active,
          slotStartAt: DateTime.utc(2026, 7, 9, 10),
          now: now,
        ),
        BookingStatusLabels.past,
      );
    });

    test('maps cancelled statuses', () {
      expect(
        BookingStatusLabels.forBooking(
          status: BookingStatus.lateCancel,
          slotStartAt: null,
          now: now,
        ),
        BookingStatusLabels.lateCancel,
      );
    });
  });
}
