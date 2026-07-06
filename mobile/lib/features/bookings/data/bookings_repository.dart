import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/vertical_api.dart';

class BookingsRepository {
  const BookingsRepository(this._api);

  final VerticalApi _api;

  Future<CreateBookingResponse> createBooking({
    required String slotId,
    required Equipment equipment,
    required String idempotencyKey,
  }) {
    return mapApiCall(
      () => _api.createBooking(
        request: CreateBookingRequest(
          slotId: slotId,
          equipment: equipment,
        ),
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  Future<BookingListResponse> listBookings({
    int offset = 0,
    int limit = 20,
  }) {
    return mapApiCall(
      () => _api.listBookings(
        ListBookingsQuery(offset: offset, limit: limit),
      ),
    );
  }

  Future<BookingDto> getBooking(String bookingId) {
    return mapApiCall(() => _api.getBooking(bookingId));
  }

  Future<BookingDto> cancelBooking(String bookingId) {
    return mapApiCall(() => _api.cancelBooking(bookingId));
  }
}
