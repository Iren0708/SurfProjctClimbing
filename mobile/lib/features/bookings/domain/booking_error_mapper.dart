import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';

class BookingErrorOutcome {
  const BookingErrorOutcome({
    required this.snackMessage,
    this.blockBooking = false,
    this.forceEquipment,
    this.updatedFreeSeats,
    this.updatedFreeRentalEquipment,
    this.regenerateIdempotencyKey = false,
  });

  final String snackMessage;
  final bool blockBooking;
  final Equipment? forceEquipment;
  final int? updatedFreeSeats;
  final int? updatedFreeRentalEquipment;
  final bool regenerateIdempotencyKey;
}

/// Маппинг ошибок createBooking (SCR-004).
abstract final class BookingErrorMapper {
  static BookingErrorOutcome map(ApiException exception) {
    final code = exception.error.code;
    final message = exception.error.message;
    final details = exception.error.details;

    return switch (code) {
      'slot_full' => BookingErrorOutcome(
          snackMessage: BookingFlowMessages.slotFull,
          blockBooking: true,
          updatedFreeSeats: details?.availableSeats ?? 0,
        ),
      'rental_unavailable' => BookingErrorOutcome(
          snackMessage: BookingFlowMessages.rentalExhausted,
          forceEquipment: Equipment.own,
          updatedFreeRentalEquipment: details?.availableRentalEquipment ?? 0,
        ),
      'double_booking' => BookingErrorOutcome(
          snackMessage: BookingFlowMessages.doubleBooking,
        ),
      'idempotency_key_conflict' => BookingErrorOutcome(
          snackMessage: message.isNotEmpty ? message : BookingFlowMessages.genericError,
          regenerateIdempotencyKey: true,
        ),
      'slot_cancelled' => BookingErrorOutcome(
          snackMessage: BookingFlowMessages.slotCancelled,
          blockBooking: true,
        ),
      'slot_started' => BookingErrorOutcome(
          snackMessage: message.isNotEmpty ? message : BookingFlowMessages.genericError,
          blockBooking: true,
        ),
      'bad_request' => BookingErrorOutcome(
          snackMessage: message.isNotEmpty ? message : BookingFlowMessages.genericError,
        ),
      _ => _mapByStatus(exception.statusCode, message),
    };
  }

  static BookingErrorOutcome _mapByStatus(int? statusCode, String message) {
    if (statusCode == 410) {
      return const BookingErrorOutcome(
        snackMessage: BookingFlowMessages.slotCancelled,
        blockBooking: true,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return const BookingErrorOutcome(
        snackMessage: BookingFlowMessages.serverError,
      );
    }
    if (statusCode == null) {
      return const BookingErrorOutcome(
        snackMessage: BookingFlowMessages.networkError,
      );
    }
    return BookingErrorOutcome(
      snackMessage: message.isNotEmpty ? message : BookingFlowMessages.genericError,
    );
  }
}
