import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/support/uuid_v4.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_notifier.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_params.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';

import '../../support/fake_bookings_repository.dart';
import '../../support/slot_test_data.dart';

void main() {
  group('SlotBookingNotifier', () {
    test('initializes with own equipment and uuid idempotency key', () {
      final slot = testSlot();
      final container = _createContainer(
        bookingsRepository: FakeBookingsRepository(),
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final state = container.read(
        slotBookingProvider(SlotBookingParams(slotId: slot.id, initialSlot: slot)),
      );

      expect(state.equipment, Equipment.own);
      expect(isUuidV4(state.idempotencyKey), isTrue);
      expect(state.slot.status, LoadableStatus.content);
    });

    test('preview uses rental price when rental selected', () {
      final slot = testSlot(freeRentalEquipment: 2);
      final container = _createContainer(
        bookingsRepository: FakeBookingsRepository(),
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final params = SlotBookingParams(slotId: slot.id, initialSlot: slot);
      container.read(slotBookingProvider(params).notifier).selectEquipment(
            Equipment.rental,
          );

      final state = container.read(slotBookingProvider(params));
      expect(state.pricePreview?.total, slot.price + slot.rentalPrice);
    });

    test('submit sends idempotency key to repository', () async {
      final slot = testSlot();
      final bookingsRepository = FakeBookingsRepository();
      final container = _createContainer(
        bookingsRepository: bookingsRepository,
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final params = SlotBookingParams(slotId: slot.id, initialSlot: slot);
      final notifier = container.read(slotBookingProvider(params).notifier);
      final idempotencyKey =
          container.read(slotBookingProvider(params)).idempotencyKey;

      await notifier.submitBooking();

      expect(bookingsRepository.lastIdempotencyKey, idempotencyKey);
      expect(
        container.read(slotBookingProvider(params)).successBooking,
        isNotNull,
      );
    });

    test('reuses idempotency key after network failure', () async {
      final slot = testSlot();
      final bookingsRepository = _FailingThenSuccessBookingsRepository();
      final container = _createContainer(
        bookingsRepository: bookingsRepository,
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final params = SlotBookingParams(slotId: slot.id, initialSlot: slot);
      final notifier = container.read(slotBookingProvider(params).notifier);
      final firstKey = container.read(slotBookingProvider(params)).idempotencyKey;

      await notifier.submitBooking();
      await notifier.submitBooking();

      expect(bookingsRepository.keys, [firstKey, firstKey]);
    });

    test('applies slot_full error and blocks booking', () async {
      final slot = testSlot(freeSeats: 1);
      final bookingsRepository = FakeBookingsRepository(
        createBookingError: ApiException(
          statusCode: 409,
          error: const ApiErrorBody(
            code: 'slot_full',
            message: 'Full',
            details: ApiErrorDetails(availableSeats: 0),
          ),
        ),
      );
      final container = _createContainer(
        bookingsRepository: bookingsRepository,
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final params = SlotBookingParams(slotId: slot.id, initialSlot: slot);
      await container.read(slotBookingProvider(params).notifier).submitBooking();

      final state = container.read(slotBookingProvider(params));
      expect(state.bookingBlocked, isTrue);
      expect(state.slot.data?.freeSeats, 0);
      expect(state.snackMessage, isNotNull);
    });

    test('applies rental_unavailable and switches to own equipment', () async {
      final slot = testSlot(freeRentalEquipment: 2);
      final bookingsRepository = FakeBookingsRepository(
        createBookingError: ApiException(
          statusCode: 409,
          error: const ApiErrorBody(
            code: 'rental_unavailable',
            message: 'No rental',
            details: ApiErrorDetails(availableRentalEquipment: 0),
          ),
        ),
      );
      final container = _createContainer(
        bookingsRepository: bookingsRepository,
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final params = SlotBookingParams(slotId: slot.id, initialSlot: slot);
      container.read(slotBookingProvider(params).notifier).selectEquipment(
            Equipment.rental,
          );
      await container.read(slotBookingProvider(params).notifier).submitBooking();

      final state = container.read(slotBookingProvider(params));
      expect(state.equipment, Equipment.own);
      expect(state.slot.data?.freeRentalEquipment, 0);
      expect(state.snackMessage, BookingFlowMessages.rentalExhausted);
    });

    test('applies 410 slot_cancelled and blocks booking', () async {
      final slot = testSlot();
      final bookingsRepository = FakeBookingsRepository(
        createBookingError: ApiException(
          statusCode: 410,
          error: const ApiErrorBody(
            code: 'slot_cancelled',
            message: 'Cancelled',
          ),
        ),
      );
      final container = _createContainer(
        bookingsRepository: bookingsRepository,
        slotsRepository: _FakeSlotsRepository(slot: slot),
      );
      addTearDown(container.dispose);

      final params = SlotBookingParams(slotId: slot.id, initialSlot: slot);
      await container.read(slotBookingProvider(params).notifier).submitBooking();

      final state = container.read(slotBookingProvider(params));
      expect(state.bookingBlocked, isTrue);
      expect(state.snackMessage, BookingFlowMessages.slotCancelled);
    });
  });
}

ProviderContainer _createContainer({
  required BookingsRepository bookingsRepository,
  required SlotsRepository slotsRepository,
}) {
  return ProviderContainer(
    overrides: [
      bookingsRepositoryProvider.overrideWithValue(bookingsRepository),
      slotsRepositoryProvider.overrideWithValue(slotsRepository),
    ],
  );
}

class _FailingThenSuccessBookingsRepository extends FakeBookingsRepository {
  final List<String> keys = [];
  var attempt = 0;

  @override
  Future<CreateBookingResponse> createBooking({
    required String slotId,
    required Equipment equipment,
    required String idempotencyKey,
  }) async {
    keys.add(idempotencyKey);
    attempt++;
    if (attempt == 1) {
      throw ApiException(
        statusCode: null,
        error: const ApiErrorBody(
          code: 'internal_error',
          message: 'Network error',
        ),
      );
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
      slot: testSlot(id: slotId),
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
