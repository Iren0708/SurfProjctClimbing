import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';

/// Расчёт доступности мест и проката (LOGIC-002).
class AvailabilityPolicy {
  const AvailabilityPolicy._();

  static int normalizeCount(int? value) {
    if (value == null || value < 0) {
      return 0;
    }
    return value;
  }

  static bool canBook({
    required int freeSeats,
    required SlotStatus status,
  }) {
    return normalizeCount(freeSeats) > 0 && status == SlotStatus.scheduled;
  }

  static bool canSelectRental(int freeRentalEquipment) {
    return normalizeCount(freeRentalEquipment) > 0;
  }

  static bool canConfirmBooking({
    required int freeSeats,
    required int freeRentalEquipment,
    required SlotStatus status,
    required Equipment equipment,
  }) {
    if (!canBook(freeSeats: freeSeats, status: status)) {
      return false;
    }
    if (equipment == Equipment.own) {
      return true;
    }
    return canSelectRental(freeRentalEquipment);
  }

  static bool canBookSlot(SlotDto slot) {
    return canBook(freeSeats: slot.freeSeats, status: slot.status);
  }

  static bool canConfirmBookingForSlot({
    required SlotDto slot,
    required Equipment equipment,
  }) {
    return canConfirmBooking(
      freeSeats: slot.freeSeats,
      freeRentalEquipment: slot.freeRentalEquipment,
      status: slot.status,
      equipment: equipment,
    );
  }

  /// При исчерпании проката принудительно переключает на «Своё».
  static Equipment normalizeEquipment({
    required Equipment equipment,
    required int freeRentalEquipment,
  }) {
    if (equipment == Equipment.rental &&
        !canSelectRental(freeRentalEquipment)) {
      return Equipment.own;
    }
    return equipment;
  }
}
