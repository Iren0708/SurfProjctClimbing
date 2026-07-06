import 'package:dio/dio.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/api_paths.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/api/vertical_api.dart';

class VerticalApiClient implements VerticalApi {
  VerticalApiClient(this._dio);

  final Dio _dio;

  @override
  Future<RequestCodeResponse> requestAuthCode(RequestCodeRequest request) {
    return mapApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiPaths.requestAuthCode,
        data: request.toJson(),
      );
      return RequestCodeResponse.fromJson(response.data!);
    });
  }

  @override
  Future<VerifyCodeResponse> verifyAuthCode(VerifyCodeRequest request) {
    return mapApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiPaths.verifyAuthCode,
        data: request.toJson(),
      );
      return VerifyCodeResponse.fromJson(response.data!);
    });
  }

  @override
  Future<TokenPair> refreshToken(RefreshTokenRequest request) {
    return mapApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiPaths.refreshToken,
        data: request.toJson(),
      );
      return TokenPair.fromJson(response.data!);
    });
  }

  @override
  Future<void> logout() {
    return mapApiCall(() async {
      await _dio.post<void>(ApiPaths.logout);
    });
  }

  @override
  Future<ClientDto> getProfile() {
    return mapApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/profile');
      return ClientDto.fromJson(response.data!);
    });
  }

  @override
  Future<ClientDto> updateProfile(UpdateProfileRequest request) {
    return mapApiCall(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/profile',
        data: request.toJson(),
      );
      return ClientDto.fromJson(response.data!);
    });
  }

  @override
  Future<void> deleteAccount() {
    return mapApiCall(() async {
      await _dio.delete<void>('/profile');
    });
  }

  @override
  Future<ZoneFormatListResponse> listZoneFormats({
    int limit = 20,
    int offset = 0,
  }) {
    return mapApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/zone-formats',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return ZoneFormatListResponse.fromJson(response.data!);
    });
  }

  @override
  Future<InstructorListResponse> listInstructors({
    int limit = 20,
    int offset = 0,
  }) {
    return mapApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/instructors',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return InstructorListResponse.fromJson(response.data!);
    });
  }

  @override
  Future<SlotListResponse> listSlots(ListSlotsQuery query) {
    return mapApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/slots',
        queryParameters: query.toQueryParameters(),
      );
      return SlotListResponse.fromJson(response.data!);
    });
  }

  @override
  Future<SlotDto> getSlot(String slotId) {
    return mapApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/slots/$slotId');
      return SlotDto.fromJson(response.data!);
    });
  }

  @override
  Future<CreateBookingResponse> createBooking({
    required CreateBookingRequest request,
    required String idempotencyKey,
  }) {
    return mapApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/bookings',
        data: request.toJson(),
        options: Options(
          headers: {'Idempotency-Key': idempotencyKey},
        ),
      );
      return CreateBookingResponse.fromJson(response.data!);
    });
  }

  @override
  Future<BookingListResponse> listBookings(ListBookingsQuery query) {
    return mapApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/bookings',
        queryParameters: query.toQueryParameters(),
      );
      return BookingListResponse.fromJson(response.data!);
    });
  }

  @override
  Future<BookingDto> getBooking(String bookingId) {
    return mapApiCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/bookings/$bookingId',
      );
      return BookingDto.fromJson(response.data!);
    });
  }

  @override
  Future<BookingDto> cancelBooking(String bookingId) {
    return mapApiCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/bookings/$bookingId/cancel',
      );
      return BookingDto.fromJson(response.data!);
    });
  }
}
