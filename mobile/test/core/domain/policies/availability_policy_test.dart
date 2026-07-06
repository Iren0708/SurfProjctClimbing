import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/availability_policy.dart';

import '../../../support/slot_test_data.dart';

void main() {
  group('AvailabilityPolicy', () {
    test('canBook is false when free_seats is 0', () {
      expect(
        AvailabilityPolicy.canBook(freeSeats: 0, status: SlotStatus.scheduled),
        isFalse,
      );
    });

    test('canBook is false when slot is cancelled', () {
      expect(
        AvailabilityPolicy.canBook(freeSeats: 3, status: SlotStatus.cancelled),
        isFalse,
      );
    });

    test('canBook is true when seats available and scheduled', () {
      expect(
        AvailabilityPolicy.canBook(freeSeats: 2, status: SlotStatus.scheduled),
        isTrue,
      );
    });

    test('negative counts are treated as zero', () {
      expect(AvailabilityPolicy.normalizeCount(-1), 0);
      expect(AvailabilityPolicy.canSelectRental(-5), isFalse);
    });

    test('rental option disabled when free_rental_equipment is 0', () {
      final slot = testSlot(freeSeats: 2, freeRentalEquipment: 0);

      expect(AvailabilityPolicy.canSelectRental(slot.freeRentalEquipment), isFalse);
      expect(
        AvailabilityPolicy.canConfirmBookingForSlot(
          slot: slot,
          equipment: Equipment.own,
        ),
        isTrue,
      );
      expect(
        AvailabilityPolicy.canConfirmBookingForSlot(
          slot: slot,
          equipment: Equipment.rental,
        ),
        isFalse,
      );
    });

    test('rental booking allowed when seats and rental available', () {
      final slot = testSlot(freeSeats: 1, freeRentalEquipment: 1);

      expect(
        AvailabilityPolicy.canConfirmBookingForSlot(
          slot: slot,
          equipment: Equipment.rental,
        ),
        isTrue,
      );
    });

    test('normalizeEquipment forces own when rental unavailable', () {
      expect(
        AvailabilityPolicy.normalizeEquipment(
          equipment: Equipment.rental,
          freeRentalEquipment: 0,
        ),
        Equipment.own,
      );
    });
  });
}
