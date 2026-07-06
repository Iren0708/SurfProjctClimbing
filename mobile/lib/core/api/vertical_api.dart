import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';

/// Контракт клиентского API (operationId из OpenAPI).
abstract class VerticalApi {
  Future<RequestCodeResponse> requestAuthCode(RequestCodeRequest request);

  Future<VerifyCodeResponse> verifyAuthCode(VerifyCodeRequest request);

  Future<TokenPair> refreshToken(RefreshTokenRequest request);

  Future<void> logout();

  Future<ClientDto> getProfile();

  Future<ClientDto> updateProfile(UpdateProfileRequest request);

  Future<void> deleteAccount();

  Future<ZoneFormatListResponse> listZoneFormats({
    int limit = 20,
    int offset = 0,
  });

  Future<InstructorListResponse> listInstructors({
    int limit = 20,
    int offset = 0,
  });

  Future<SlotListResponse> listSlots(ListSlotsQuery query);

  Future<SlotDto> getSlot(String slotId);

  Future<CreateBookingResponse> createBooking({
    required CreateBookingRequest request,
    required String idempotencyKey,
  });

  Future<BookingListResponse> listBookings(ListBookingsQuery query);

  Future<BookingDto> getBooking(String bookingId);

  Future<BookingDto> cancelBooking(String bookingId);
}
