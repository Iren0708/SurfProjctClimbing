import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository.dart';

import 'booking_test_data.dart';

/// Тестовый репозиторий броней с дефолтными заглушками для всех методов.
class FakeBookingsRepository implements BookingsRepository {
  FakeBookingsRepository({
    this.createBookingError,
    this.listItems,
    this.getBookingResult,
    this.cancelBookingResult,
    this.cancelBookingError,
  });

  final ApiException? createBookingError;
  final List<BookingSummaryDto>? listItems;
  final BookingDto? getBookingResult;
  final BookingDto? cancelBookingResult;
  final ApiException? cancelBookingError;

  String? lastIdempotencyKey;
  Equipment? lastEquipment;
  String? lastCancelledBookingId;

  @override
  Future<CreateBookingResponse> createBooking({
    required String slotId,
    required Equipment equipment,
    required String idempotencyKey,
  }) async {
    lastIdempotencyKey = idempotencyKey;
    lastEquipment = equipment;
    if (createBookingError != null) {
      throw createBookingError!;
    }
    return CreateBookingResponse(
      id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      slotId: slotId,
      clientId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      equipment: equipment,
      status: BookingStatus.active,
      priceTotal: 1200,
      createdAt: DateTime.utc(2026, 7, 10, 10),
      isFirstBooking: false,
      reminderHours: const [24, 2],
      slot: testBooking(slotId: slotId).slot,
    );
  }

  @override
  Future<BookingListResponse> listBookings({
    int offset = 0,
    int limit = 20,
  }) async {
    final items = listItems ?? [testBookingSummary()];
    return BookingListResponse(
      items: items,
      meta: PaginationMeta(limit: limit, offset: offset, total: items.length),
    );
  }

  @override
  Future<BookingDto> getBooking(String bookingId) async {
    return getBookingResult ?? testBooking(id: bookingId);
  }

  @override
  Future<BookingDto> cancelBooking(String bookingId) async {
    lastCancelledBookingId = bookingId;
    if (cancelBookingError != null) {
      throw cancelBookingError!;
    }
    return cancelBookingResult ??
        testBooking(
          id: bookingId,
          status: BookingStatus.cancelled,
        );
  }
}
