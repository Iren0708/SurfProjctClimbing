import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_error_mapper.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';

void main() {
  group('BookingErrorMapper', () {
    test('maps slot_full with available seats', () {
      final outcome = BookingErrorMapper.map(
        ApiException(
          statusCode: 409,
          error: const ApiErrorBody(
            code: 'slot_full',
            message: 'Slot full',
            details: ApiErrorDetails(availableSeats: 0),
          ),
        ),
      );

      expect(outcome.snackMessage, BookingFlowMessages.slotFull);
      expect(outcome.blockBooking, isTrue);
      expect(outcome.updatedFreeSeats, 0);
    });

    test('maps rental_unavailable to own equipment', () {
      final outcome = BookingErrorMapper.map(
        ApiException(
          statusCode: 409,
          error: const ApiErrorBody(
            code: 'rental_unavailable',
            message: 'No rental',
            details: ApiErrorDetails(availableRentalEquipment: 0),
          ),
        ),
      );

      expect(outcome.snackMessage, BookingFlowMessages.rentalExhausted);
      expect(outcome.forceEquipment, Equipment.own);
      expect(outcome.updatedFreeRentalEquipment, 0);
    });

    test('maps 410 slot_cancelled', () {
      final outcome = BookingErrorMapper.map(
        ApiException(
          statusCode: 410,
          error: const ApiErrorBody(
            code: 'slot_cancelled',
            message: 'Cancelled',
          ),
        ),
      );

      expect(outcome.snackMessage, BookingFlowMessages.slotCancelled);
      expect(outcome.blockBooking, isTrue);
    });

    test('defaults rental equipment to zero when details missing', () {
      final outcome = BookingErrorMapper.map(
        ApiException(
          statusCode: 409,
          error: const ApiErrorBody(
            code: 'rental_unavailable',
            message: 'No rental',
          ),
        ),
      );

      expect(outcome.snackMessage, BookingFlowMessages.rentalExhausted);
      expect(outcome.forceEquipment, Equipment.own);
      expect(outcome.updatedFreeRentalEquipment, 0);
    });

    test('maps network errors', () {
      final outcome = BookingErrorMapper.map(
        ApiException(
          statusCode: null,
          error: const ApiErrorBody(
            code: 'internal_error',
            message: 'Network error',
          ),
        ),
      );

      expect(outcome.snackMessage, BookingFlowMessages.networkError);
    });
  });
}
