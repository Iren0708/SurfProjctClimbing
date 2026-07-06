import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/availability_policy.dart';
import 'package:vertical_mobile/core/support/uuid_v4.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_error_mapper.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_params.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_state.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';

class SlotBookingNotifier
    extends AutoDisposeFamilyNotifier<SlotBookingState, SlotBookingParams> {
  @override
  SlotBookingState build(SlotBookingParams params) {
    final idempotencyKey = generateUuidV4();
    final initialSlot = params.initialSlot;
    if (initialSlot != null && initialSlot.id == params.slotId) {
      return SlotBookingState.ready(
        slot: initialSlot,
        idempotencyKey: idempotencyKey,
      );
    }
    Future<void>.microtask(loadSlot);
    return SlotBookingState.loading(idempotencyKey: idempotencyKey);
  }

  Future<void> loadSlot() async {
    final slotId = arg.slotId;
    final currentKey = state.idempotencyKey;
    state = SlotBookingState.loading(idempotencyKey: currentKey);
    try {
      final slot = await ref.read(slotsRepositoryProvider).getSlot(slotId);
      state = SlotBookingState.ready(slot: slot, idempotencyKey: currentKey);
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        state = SlotBookingState(
          slot: LoadableState<SlotDto>.error(
            message: BookingFlowMessages.slotNotFound,
          ),
          equipment: Equipment.own,
          idempotencyKey: currentKey,
          submitState: const ActionLoadableState.idle(),
          bookingBlocked: true,
        );
        return;
      }
      state = SlotBookingState(
        slot: LoadableState<SlotDto>.error(),
        equipment: Equipment.own,
        idempotencyKey: currentKey,
        submitState: const ActionLoadableState.idle(),
      );
    } catch (_) {
      state = SlotBookingState(
        slot: LoadableState<SlotDto>.error(),
        equipment: Equipment.own,
        idempotencyKey: currentKey,
        submitState: const ActionLoadableState.idle(),
      );
    }
  }

  Future<void> refreshSlot() async {
    final slotData = state.slot.data;
    if (slotData == null) {
      await loadSlot();
      return;
    }

    state = state.copyWith(
      slot: LoadableState.content(slotData, isRefreshing: true),
      clearRefreshError: true,
    );

    try {
      final slot = await ref.read(slotsRepositoryProvider).getSlot(arg.slotId);
      state = SlotBookingState.ready(
        slot: slot,
        idempotencyKey: state.idempotencyKey,
      ).copyWith(
        equipment: AvailabilityPolicy.normalizeEquipment(
          equipment: state.equipment,
          freeRentalEquipment: slot.freeRentalEquipment,
        ),
        bookingBlocked: state.bookingBlocked,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        state = state.copyWith(
          slot: LoadableState.content(slotData),
          bookingBlocked: true,
          snackMessage: BookingFlowMessages.slotNotFound,
        );
        return;
      }
      state = state.copyWith(
        slot: LoadableState.content(slotData),
        refreshError: LoadableMessages.refreshError,
      );
    } catch (_) {
      state = state.copyWith(
        slot: LoadableState.content(slotData),
        refreshError: LoadableMessages.refreshError,
      );
    }
  }

  void selectEquipment(Equipment equipment) {
    if (state.submitState.isSubmitting) {
      return;
    }
    final slot = state.slot.data;
    if (slot == null) {
      return;
    }

    final normalized = AvailabilityPolicy.normalizeEquipment(
      equipment: equipment,
      freeRentalEquipment: slot.freeRentalEquipment,
    );

    var nextKey = state.idempotencyKey;
    if (state.awaitIdempotencyRegeneration && normalized != state.equipment) {
      nextKey = generateUuidV4();
    }

    state = state.copyWith(
      equipment: normalized,
      idempotencyKey: nextKey,
      awaitIdempotencyRegeneration: false,
    );
  }

  Future<void> submitBooking() async {
    if (!state.canConfirm || state.submitState.isSubmitting) {
      return;
    }

    final slot = state.slot.data!;
    state = state.copyWith(
      submitState: const ActionLoadableState.submitting(),
      clearSnack: true,
    );

    try {
      final response = await ref.read(bookingsRepositoryProvider).createBooking(
            slotId: slot.id,
            equipment: state.equipment,
            idempotencyKey: state.idempotencyKey,
          );
      state = state.copyWith(
        submitState: const ActionLoadableState.idle(),
        successBooking: response,
      );
    } on ApiException catch (error) {
      _applyBookingError(error);
    } catch (_) {
      state = state.copyWith(
        submitState: const ActionLoadableState.idle(),
        snackMessage: BookingFlowMessages.networkError,
      );
    }
  }

  void _applyBookingError(ApiException error) {
    final outcome = BookingErrorMapper.map(error);
    var slotState = state.slot;
    var equipment = state.equipment;
    var bookingBlocked = state.bookingBlocked;
    var idempotencyKey = state.idempotencyKey;
    var awaitRegeneration = state.awaitIdempotencyRegeneration;

    if (outcome.updatedFreeSeats != null && slotState.data != null) {
      final current = slotState.data!;
      slotState = LoadableState.content(
        _copySlotAvailability(
          current,
          freeSeats: outcome.updatedFreeSeats,
        ),
      );
    }

    if (outcome.updatedFreeRentalEquipment != null && slotState.data != null) {
      final current = slotState.data!;
      slotState = LoadableState.content(
        _copySlotAvailability(
          current,
          freeRentalEquipment: outcome.updatedFreeRentalEquipment,
        ),
      );
    }

    if (outcome.forceEquipment != null) {
      equipment = outcome.forceEquipment!;
    }

    if (outcome.blockBooking) {
      bookingBlocked = true;
    }

    if (outcome.regenerateIdempotencyKey) {
      awaitRegeneration = true;
    }

    state = state.copyWith(
      slot: slotState,
      equipment: equipment,
      bookingBlocked: bookingBlocked,
      idempotencyKey: idempotencyKey,
      awaitIdempotencyRegeneration: awaitRegeneration,
      submitState: const ActionLoadableState.idle(),
      snackMessage: outcome.snackMessage,
    );
  }

  SlotDto _copySlotAvailability(
    SlotDto slot, {
    int? freeSeats,
    int? freeRentalEquipment,
  }) {
    return SlotDto(
      id: slot.id,
      startAt: slot.startAt,
      zoneFormat: slot.zoneFormat,
      instructorInfo: slot.instructorInfo,
      totalSeats: slot.totalSeats,
      freeSeats: freeSeats ?? slot.freeSeats,
      freeRentalEquipment: freeRentalEquipment ?? slot.freeRentalEquipment,
      price: slot.price,
      rentalPrice: slot.rentalPrice,
      status: slot.status,
    );
  }

  void clearSnack() {
    if (state.snackMessage != null) {
      state = state.copyWith(clearSnack: true);
    }
  }

  void clearRefreshError() {
    if (state.refreshError != null) {
      state = state.copyWith(clearRefreshError: true);
    }
  }

  void clearSuccess() {
    if (state.successBooking != null) {
      state = state.copyWith(clearSuccess: true);
    }
  }
}

final slotBookingProvider = NotifierProvider.autoDispose
    .family<SlotBookingNotifier, SlotBookingState, SlotBookingParams>(
  SlotBookingNotifier.new,
);
