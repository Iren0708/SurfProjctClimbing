import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/app/router/app_shell_branch.dart';
import 'package:vertical_mobile/app/vertical_app.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_details_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_list_messages.dart';
import 'package:vertical_mobile/features/profile/data/profile_repository.dart';
import 'package:vertical_mobile/features/profile/data/profile_repository_provider.dart';
import 'package:vertical_mobile/features/profile/domain/profile_messages.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';

import '../../support/booking_test_data.dart';
import '../../support/in_memory_token_storage.dart';
import '../../support/slot_test_data.dart';

/// Widget-level проверка переходов feature-list §3 (MOB-18).
void main() {
  group('Navigation flows (feature-list §3)', () {
    testWidgets('tab bar switches SCR-002 ↔ SCR-005 ↔ SCR-007', (tester) async {
      await _pumpAuthenticatedApp(tester);

      await tester.tap(find.byIcon(Icons.event_note_outlined));
      await tester.pumpAndSettle();
      expect(find.text(BookingListMessages.upcomingSection), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text(ProfileMessages.phoneLabel), findsOneWidget);

      await tester.tap(find.byIcon(Icons.fitness_center_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Новичковый'), findsWidgets);
    });

    testWidgets('SCR-002 → SCR-003 → SCR-004', (tester) async {
      final slot = testSlot();
      await _pumpAuthenticatedApp(tester, slot: slot);

      await tester.tap(find.text('Новичковый').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Записаться'));
      await tester.pumpAndSettle();

      expect(find.text(BookingFlowMessages.title), findsOneWidget);
      expect(find.text(BookingFlowMessages.confirm), findsOneWidget);
    });

    testWidgets('SCR-005 → SCR-006', (tester) async {
      final booking = testBookingSummary();
      await _pumpAuthenticatedApp(
        tester,
        bookings: [booking],
      );

      await tester.tap(find.byIcon(Icons.event_note_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Новичковый').first);
      await tester.pumpAndSettle();

      expect(find.text(BookingDetailsMessages.title), findsOneWidget);
    });

    testWidgets('logout on SCR-007 returns to SCR-001', (tester) async {
      await _pumpAuthenticatedApp(tester);

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(OutlinedButton, ProfileMessages.logoutAction),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, ProfileMessages.logoutConfirm));
      await tester.pumpAndSettle();

      expect(find.text('Получить код'), findsOneWidget);
    });
  });
}

Future<void> _pumpAuthenticatedApp(
  WidgetTester tester, {
  SlotDto? slot,
  List<BookingSummaryDto>? bookings,
}) async {
  final seedSlot = slot ?? testSlot();
  final storage = InMemoryTokenStorage()
    ..refreshToken = 'refresh-token'
    ..accessToken = 'access-token';

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(storage),
        slotsRepositoryProvider.overrideWithValue(
          _NavSlotsRepository(seedSlot),
        ),
        bookingsRepositoryProvider.overrideWithValue(
          _NavBookingsRepository(bookings ?? [testBookingSummary()]),
        ),
        profileRepositoryProvider.overrideWithValue(_NavProfileRepository()),
      ],
      child: const VerticalApp(),
    ),
  );

  await tester.pump();
  await tester.pumpAndSettle();
}

class _NavSlotsRepository implements SlotsRepository {
  _NavSlotsRepository(this.slot);

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

class _NavBookingsRepository implements BookingsRepository {
  _NavBookingsRepository(this.items);

  final List<BookingSummaryDto> items;

  @override
  Future<CreateBookingResponse> createBooking({
    required String slotId,
    required Equipment equipment,
    required String idempotencyKey,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<BookingListResponse> listBookings({
    int offset = 0,
    int limit = 20,
  }) async {
    return BookingListResponse(
      items: items,
      meta: PaginationMeta(limit: limit, offset: offset, total: items.length),
    );
  }

  @override
  Future<BookingDto> getBooking(String bookingId) async {
    return testBooking(id: bookingId);
  }

  @override
  Future<BookingDto> cancelBooking(String bookingId) async {
    return testBooking(id: bookingId, status: BookingStatus.cancelled);
  }
}

class _NavProfileRepository implements ProfileRepository {
  @override
  Future<ClientDto> getProfile() async {
    return ClientDto(
      id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      name: 'Ирина',
      phone: '+79001234567',
      createdAt: DateTime.utc(2026, 7, 6),
    );
  }

  @override
  Future<ClientDto> updateProfile(String name) async {
    return getProfile();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount() async {}
}
