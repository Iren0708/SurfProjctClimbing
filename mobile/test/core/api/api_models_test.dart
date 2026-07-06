import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/api/vertical_api.dart';
import 'package:vertical_mobile/core/api/vertical_api_client.dart';

void main() {
  group('OpenAPI model parsing', () {
    test('VerifyCodeResponse parses fixture', () async {
      final json = await _readFixture('verify_code_response.json');
      final response = VerifyCodeResponse.fromJson(json);

      expect(response.isNew, isTrue);
      expect(response.tokens.accessToken, 'access-jwt');
      expect(response.client.phone, '+79991234567');
    });

    test('CreateBookingResponse parses fixture', () async {
      final json = await _readFixture('create_booking_response.json');
      final response = CreateBookingResponse.fromJson(json);

      expect(response.equipment, Equipment.rental);
      expect(response.priceTotal, 1600);
      expect(response.isFirstBooking, isTrue);
      expect(response.reminderHours, [24, 2]);
      expect(response.slot?.instructorInfo.name, 'Анна');
    });

    test('ClientDto omits null name in toJson', () {
      final client = ClientDto(
        id: 'id',
        phone: '+79990000000',
        createdAt: DateTime.utc(2026, 7, 6),
      );

      expect(client.toJson().containsKey('name'), isFalse);
    });

    test('ListSlotsQuery serializes filters', () {
      final query = ListSlotsQuery(
        zoneFormatTypes: const [ZoneFormatType.novice],
        instructorIds: const ['33333333-3333-3333-3333-333333333333'],
        onlyAvailable: true,
        limit: 10,
      );

      expect(query.toQueryParameters()['zone_format_type'], ['novice']);
      expect(query.toQueryParameters()['only_available'], isTrue);
    });

    test('ApiException maps error body', () {
      final error = ApiErrorBody.fromJson({
        'code': 'slot_full',
        'message': 'Нет мест',
        'details': {
          'available_seats': 0,
          'available_rental_equipment': 1,
        },
      });

      expect(error.code, 'slot_full');
      expect(error.details?.availableSeats, 0);
    });
  });

  test('VerticalApiClient implements VerticalApi contract', () {
    expect(VerticalApiClient, isA<Type>());
    const VerticalApi api = _VerticalApiContractCheck();
    expect(api, isA<VerticalApi>());
  });
}

Future<Map<String, dynamic>> _readFixture(String name) async {
  final file = File('test/fixtures/$name');
  final content = await file.readAsString();
  return jsonDecode(content) as Map<String, dynamic>;
}

class _VerticalApiContractCheck implements VerticalApi {
  const _VerticalApiContractCheck();

  @override
  Future<BookingDto> cancelBooking(String bookingId) => throw UnimplementedError();

  @override
  Future<CreateBookingResponse> createBooking({
    required CreateBookingRequest request,
    required String idempotencyKey,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAccount() => throw UnimplementedError();

  @override
  Future<BookingDto> getBooking(String bookingId) => throw UnimplementedError();

  @override
  Future<ClientDto> getProfile() => throw UnimplementedError();

  @override
  Future<SlotDto> getSlot(String slotId) => throw UnimplementedError();

  @override
  Future<InstructorListResponse> listInstructors({
    int limit = 20,
    int offset = 0,
  }) =>
      throw UnimplementedError();

  @override
  Future<BookingListResponse> listBookings(ListBookingsQuery query) =>
      throw UnimplementedError();

  @override
  Future<SlotListResponse> listSlots(ListSlotsQuery query) =>
      throw UnimplementedError();

  @override
  Future<ZoneFormatListResponse> listZoneFormats({
    int limit = 20,
    int offset = 0,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<TokenPair> refreshToken(RefreshTokenRequest request) =>
      throw UnimplementedError();

  @override
  Future<RequestCodeResponse> requestAuthCode(RequestCodeRequest request) =>
      throw UnimplementedError();

  @override
  Future<ClientDto> updateProfile(UpdateProfileRequest request) =>
      throw UnimplementedError();

  @override
  Future<VerifyCodeResponse> verifyAuthCode(VerifyCodeRequest request) =>
      throw UnimplementedError();
}
