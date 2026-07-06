import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_screen.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';

import '../../support/fake_bookings_repository.dart';
import '../../support/slot_test_data.dart';

void main() {
  testWidgets('shows equipment radios without seat counter', (tester) async {
    final slot = testSlot(freeRentalEquipment: 2);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          slotsRepositoryProvider.overrideWithValue(
            _FakeSlotsRepository(slot: slot),
          ),
          bookingsRepositoryProvider.overrideWithValue(
            FakeBookingsRepository(),
          ),
        ],
        child: MaterialApp(
          home: SlotBookingScreen(slotId: slot.id, initialSlot: slot),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(BookingFlowMessages.title), findsOneWidget);
    expect(find.text(BookingFlowMessages.ownEquipment), findsOneWidget);
    expect(find.text(BookingFlowMessages.rentalEquipment), findsOneWidget);
    expect(find.textContaining('Итого:'), findsOneWidget);
    expect(find.textContaining('Оплата на месте'), findsOneWidget);
    expect(find.textContaining('Места:'), findsNothing);
  });

  testWidgets('disables rental option when free_rental_equipment is zero', (
    tester,
  ) async {
    final slot = testSlot(freeRentalEquipment: 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          slotsRepositoryProvider.overrideWithValue(
            _FakeSlotsRepository(slot: slot),
          ),
          bookingsRepositoryProvider.overrideWithValue(
            FakeBookingsRepository(),
          ),
        ],
        child: MaterialApp(
          home: SlotBookingScreen(slotId: slot.id, initialSlot: slot),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(BookingFlowMessages.rentalUnavailable), findsOneWidget);

    await tester.tap(find.text(BookingFlowMessages.rentalEquipment));
    await tester.pumpAndSettle();

    expect(find.textContaining('1200 ₽'), findsOneWidget);
  });

  testWidgets('updates total when rental is selected', (tester) async {
    final slot = testSlot(freeRentalEquipment: 2, price: 1200, rentalPrice: 400);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          slotsRepositoryProvider.overrideWithValue(
            _FakeSlotsRepository(slot: slot),
          ),
          bookingsRepositoryProvider.overrideWithValue(
            FakeBookingsRepository(),
          ),
        ],
        child: MaterialApp(
          home: SlotBookingScreen(slotId: slot.id, initialSlot: slot),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text(BookingFlowMessages.rentalEquipment));
    await tester.pumpAndSettle();

    expect(find.textContaining('1600 ₽'), findsOneWidget);
  });

  testWidgets('confirm button stays enabled with zero rental stock', (
    tester,
  ) async {
    final slot = testSlot(freeSeats: 2, freeRentalEquipment: 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          slotsRepositoryProvider.overrideWithValue(
            _FakeSlotsRepository(slot: slot),
          ),
          bookingsRepositoryProvider.overrideWithValue(
            FakeBookingsRepository(),
          ),
        ],
        child: MaterialApp(
          home: SlotBookingScreen(slotId: slot.id, initialSlot: slot),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, BookingFlowMessages.confirm),
    );
    expect(button.onPressed, isNotNull);
  });
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
