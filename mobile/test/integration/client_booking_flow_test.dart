import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/session/auth_session_status.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/auth/data/auth_repository.dart';
import 'package:vertical_mobile/features/auth/data/auth_repository_provider.dart';
import 'package:vertical_mobile/features/auth/presentation/auth_flow_notifier.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_details_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/booking_details_notifier.dart';
import 'package:vertical_mobile/features/bookings/presentation/bookings_list_notifier.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_notifier.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_params.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';

import '../support/booking_test_data.dart';
import '../support/in_memory_token_storage.dart';
import '../support/slot_test_data.dart';

/// UC-1…UC-4: auth → book → list → cancel через notifier-слой (MOB-16).
void main() {
  group('Client booking flow', () {
    test('auth → book → list → cancel', () async {
      final slot = testSlot(freeSeats: 5, freeRentalEquipment: 2);
      final bookingsRepository = _FlowBookingsRepository(slot: slot);
      final container = _createContainer(
        authRepository: _FakeAuthRepository(),
        bookingsRepository: bookingsRepository,
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final authNotifier = container.read(authFlowProvider.notifier);
      authNotifier.updatePhoneInput('9991234567');
      expect(await authNotifier.requestCode(), isNull);
      authNotifier.updateOtpCode('1234');
      expect(await authNotifier.verifyCode(), isNull);
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.authenticated,
      );

      final bookingParams = SlotBookingParams(slotId: slot.id, initialSlot: slot);
      final bookingSubscription = container.listen(
        slotBookingProvider(bookingParams),
        (_, __) {},
      );
      addTearDown(bookingSubscription.close);

      await container.read(slotBookingProvider(bookingParams).notifier).submitBooking();
      final created = container.read(slotBookingProvider(bookingParams)).successBooking;
      expect(created, isNotNull);

      final listSubscription = container.listen(
        bookingsListProvider,
        (_, __) {},
      );
      addTearDown(listSubscription.close);
      await container.read(bookingsListProvider.notifier).loadInitial();
      await Future<void>.delayed(Duration.zero);

      final listState = container.read(bookingsListProvider);
      expect(listState.bookings.status, LoadableStatus.content);
      expect(listState.bookings.data, hasLength(1));
      expect(listState.bookings.data!.first.id, created!.id);

      final bookingId = created.id;
      final detailsSubscription = container.listen(
        bookingDetailsProvider(bookingId),
        (_, __) {},
      );
      addTearDown(detailsSubscription.close);
      await Future<void>.delayed(Duration.zero);

      await container.read(bookingDetailsProvider(bookingId).notifier).cancelBooking();

      final detailsState = container.read(bookingDetailsProvider(bookingId));
      expect(detailsState.successSnack, BookingDetailsMessages.earlyCancelSuccess);
      expect(detailsState.booking.data?.status, BookingStatus.cancelled);
      expect(bookingsRepository.cancelledIds, contains(bookingId));
    });
  });
}

ProviderContainer _createContainer({
  required AuthRepository authRepository,
  required BookingsRepository bookingsRepository,
  required SlotsRepository slotsRepository,
}) {
  return ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
      authRepositoryProvider.overrideWithValue(authRepository),
      bookingsRepositoryProvider.overrideWithValue(bookingsRepository),
      slotsRepositoryProvider.overrideWithValue(slotsRepository),
    ],
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<RequestCodeResponse> requestCode(String phone) async {
    return const RequestCodeResponse(ttlSeconds: 300, resendAfterSeconds: 30);
  }

  @override
  Future<VerifyCodeResponse> verifyCode({
    required String phone,
    required String code,
  }) async {
    return VerifyCodeResponse(
      tokens: const TokenPair(
        accessToken: 'access',
        refreshToken: 'refresh',
        tokenType: 'Bearer',
        expiresIn: 900,
      ),
      client: ClientDto(
        id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        phone: phone,
        name: 'Ирина',
        createdAt: DateTime.utc(2026, 7, 6),
      ),
      isNew: false,
    );
  }

  @override
  Future<ClientDto> updateProfile(String name) async {
    return ClientDto(
      id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      phone: '+79991234567',
      name: name,
      createdAt: DateTime.utc(2026, 7, 6),
    );
  }
}

class _FakeSlotsRepository implements SlotsRepository {
  _FakeSlotsRepository({required this.slot});

  final SlotDto slot;

  @override
  Future<SlotListResponse> listSlots(
    SlotFilters filters, {
    int offset = 0,
    int limit = 20,
  }) async {
    return SlotListResponse(
      items: [slot],
      meta: const PaginationMeta(limit: 20, offset: 0, total: 1),
    );
  }

  @override
  Future<SlotDto> getSlot(String slotId) async => slot;
}

class _FlowBookingsRepository implements BookingsRepository {
  _FlowBookingsRepository({required this.slot});

  final SlotDto slot;
  final List<BookingSummaryDto> _summaries = [];
  BookingDto? _details;
  final Set<String> cancelledIds = {};

  @override
  Future<CreateBookingResponse> createBooking({
    required String slotId,
    required Equipment equipment,
    required String idempotencyKey,
  }) async {
    final response = CreateBookingResponse(
      id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      slotId: slotId,
      clientId: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      equipment: equipment,
      status: BookingStatus.active,
      priceTotal: slot.price + (equipment == Equipment.rental ? slot.rentalPrice : 0),
      createdAt: DateTime.utc(2026, 7, 10, 9),
      isFirstBooking: false,
      reminderHours: const [24, 2],
      slot: slot,
    );
    _details = response;
    _summaries
      ..clear()
      ..add(
        BookingSummaryDto(
          id: response.id,
          slotId: response.slotId,
          equipment: response.equipment,
          status: response.status,
          priceTotal: response.priceTotal,
          createdAt: response.createdAt,
          slot: slot,
        ),
      );
    return response;
  }

  @override
  Future<BookingListResponse> listBookings({
    int offset = 0,
    int limit = 20,
  }) async {
    return BookingListResponse(
      items: List<BookingSummaryDto>.from(_summaries),
      meta: PaginationMeta(
        limit: limit,
        offset: offset,
        total: _summaries.length,
      ),
    );
  }

  @override
  Future<BookingDto> getBooking(String bookingId) async {
    final booking = _details;
    if (booking == null || booking.id != bookingId) {
      throw StateError('Booking not found');
    }
    return booking;
  }

  @override
  Future<BookingDto> cancelBooking(String bookingId) async {
    cancelledIds.add(bookingId);
    final booking = testBooking(
      id: bookingId,
      status: BookingStatus.cancelled,
      slotStartAt: slot.startAt,
    );
    _details = booking;
    if (_summaries.isNotEmpty) {
      final summary = _summaries.first;
      _summaries[0] = BookingSummaryDto(
        id: summary.id,
        slotId: summary.slotId,
        equipment: summary.equipment,
        status: BookingStatus.cancelled,
        priceTotal: summary.priceTotal,
        createdAt: summary.createdAt,
        slot: summary.slot,
      );
    }
    return booking;
  }
}
