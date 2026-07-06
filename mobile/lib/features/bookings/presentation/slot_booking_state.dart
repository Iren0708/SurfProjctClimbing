import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/availability_policy.dart';
import 'package:vertical_mobile/core/domain/policies/booking_price_calculator.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';

class SlotBookingState {
  const SlotBookingState({
    required this.slot,
    required this.equipment,
    required this.idempotencyKey,
    required this.submitState,
    this.bookingBlocked = false,
    this.awaitIdempotencyRegeneration = false,
    this.successBooking,
    this.snackMessage,
    this.refreshError,
  });

  final LoadableState<SlotDto> slot;
  final Equipment equipment;
  final String idempotencyKey;
  final ActionLoadableState submitState;
  final bool bookingBlocked;
  final bool awaitIdempotencyRegeneration;
  final CreateBookingResponse? successBooking;
  final String? snackMessage;
  final String? refreshError;

  factory SlotBookingState.loading({required String idempotencyKey}) {
    return SlotBookingState(
      slot: LoadableState<SlotDto>.loading(),
      equipment: Equipment.own,
      idempotencyKey: idempotencyKey,
      submitState: const ActionLoadableState.idle(),
    );
  }

  factory SlotBookingState.ready({
    required SlotDto slot,
    required String idempotencyKey,
  }) {
    final equipment = AvailabilityPolicy.normalizeEquipment(
      equipment: Equipment.own,
      freeRentalEquipment: slot.freeRentalEquipment,
    );
    return SlotBookingState(
      slot: LoadableState.content(slot),
      equipment: equipment,
      idempotencyKey: idempotencyKey,
      submitState: const ActionLoadableState.idle(),
    );
  }

  bool get canSelectRental {
    final slotData = slot.data;
    if (slotData == null) {
      return false;
    }
    return AvailabilityPolicy.canSelectRental(slotData.freeRentalEquipment);
  }

  bool get canConfirm {
    final slotData = slot.data;
    if (slotData == null || bookingBlocked) {
      return false;
    }
    if (!AvailabilityPolicy.canConfirmBookingForSlot(
      slot: slotData,
      equipment: equipment,
    )) {
      return false;
    }
    return BookingPriceCalculator.preview(
      price: slotData.price,
      rentalPrice: slotData.rentalPrice,
      equipment: equipment,
    ).isValid;
  }

  BookingPriceBreakdown? get pricePreview {
    final slotData = slot.data;
    if (slotData == null) {
      return null;
    }
    final preview = BookingPriceCalculator.preview(
      price: slotData.price,
      rentalPrice: slotData.rentalPrice,
      equipment: equipment,
    );
    return preview.isValid ? preview : null;
  }

  SlotBookingState copyWith({
    LoadableState<SlotDto>? slot,
    Equipment? equipment,
    String? idempotencyKey,
    ActionLoadableState? submitState,
    bool? bookingBlocked,
    bool? awaitIdempotencyRegeneration,
    CreateBookingResponse? successBooking,
    String? snackMessage,
    String? refreshError,
    bool clearSnack = false,
    bool clearSuccess = false,
    bool clearRefreshError = false,
  }) {
    return SlotBookingState(
      slot: slot ?? this.slot,
      equipment: equipment ?? this.equipment,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      submitState: submitState ?? this.submitState,
      bookingBlocked: bookingBlocked ?? this.bookingBlocked,
      awaitIdempotencyRegeneration:
          awaitIdempotencyRegeneration ?? this.awaitIdempotencyRegeneration,
      successBooking: clearSuccess ? null : (successBooking ?? this.successBooking),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
      refreshError:
          clearRefreshError ? null : (refreshError ?? this.refreshError),
    );
  }
}
