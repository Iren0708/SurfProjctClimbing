import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/api/vertical_api_client.dart';
import 'package:vertical_mobile/core/support/uuid_v4.dart';

/// E2E smoke против локального API (MOB-17).
///
/// Запуск:
/// ```bash
/// docker compose up -d
/// flutter test test/e2e/api_smoke_test.dart --dart-define=RUN_E2E=true
/// ```
const _runE2e = bool.fromEnvironment('RUN_E2E');
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/v1',
);
const _healthUrl = String.fromEnvironment(
  'API_HEALTH_URL',
  defaultValue: 'http://localhost:8080/health',
);
const _e2ePhone = String.fromEnvironment(
  'E2E_PHONE',
  defaultValue: '+79009998877',
);
const _e2eOtp = String.fromEnvironment('E2E_OTP', defaultValue: '1234');

void main() {
  group('API E2E smoke (docker compose)', () {
    test(
      'UC-1 auth → UC-3 book → UC-4 list → cancel',
      () async {
        final healthDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        final health = await healthDio.get<Map<String, dynamic>>(_healthUrl);
        expect(health.statusCode, 200);
        expect(health.data?['status'], 'UP');

        final publicDio = Dio(
          BaseOptions(
            baseUrl: _apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: const {'Accept': 'application/json'},
          ),
        );
        final publicApi = VerticalApiClient(publicDio);

        await publicApi.requestAuthCode(RequestCodeRequest(phone: _e2ePhone));
        final auth = await publicApi.verifyAuthCode(
          VerifyCodeRequest(phone: _e2ePhone, code: _e2eOtp),
        );

        final authedDio = Dio(
          BaseOptions(
            baseUrl: _apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer ${auth.tokens.accessToken}',
            },
          ),
        );
        final api = VerticalApiClient(authedDio);

        if (auth.isNew) {
          await api.updateProfile(
            const UpdateProfileRequest(name: 'E2E Smoke'),
          );
        }

        final slots = await api.listSlots(const ListSlotsQuery(limit: 20));
        expect(slots.items, isNotEmpty);

        final slot = slots.items.firstWhere(
          (item) => item.freeSeats > 0 && item.status == SlotStatus.scheduled,
          orElse: () => throw StateError('No bookable slot in seed data'),
        );

        final booking = await api.createBooking(
          request: CreateBookingRequest(
            slotId: slot.id,
            equipment: Equipment.own,
          ),
          idempotencyKey: generateUuidV4(),
        );
        expect(booking.status, BookingStatus.active);

        final list = await api.listBookings(
          const ListBookingsQuery(limit: 20),
        );
        expect(
          list.items.any((item) => item.id == booking.id),
          isTrue,
        );

        final cancelled = await api.cancelBooking(booking.id);
        expect(
          cancelled.status,
          anyOf(BookingStatus.cancelled, BookingStatus.lateCancel),
        );

        await api.logout();
      },
      skip: _runE2e ? false : 'Pass --dart-define=RUN_E2E=true after docker compose up',
    );
  });
}
