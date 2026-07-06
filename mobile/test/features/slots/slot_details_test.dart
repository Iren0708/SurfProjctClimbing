import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';
import 'package:vertical_mobile/features/slots/domain/slot_details_messages.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_details_notifier.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_details_screen.dart';

import '../../support/slot_test_data.dart';

void main() {
  group('SlotDetailsNotifier', () {
    test('loads slot on init', () async {
      final slot = testSlot();
      final container = ProviderContainer(
        overrides: [
          slotsRepositoryProvider.overrideWithValue(
            _FakeSlotsRepository(slot: slot),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(slotDetailsProvider(slot.id).notifier).loadInitial();

      final state = container.read(slotDetailsProvider(slot.id));
      expect(state.slot.status, LoadableStatus.content);
      expect(state.slot.data?.id, slot.id);
    });

    test('maps 404 to not found error', () async {
      final container = ProviderContainer(
        overrides: [
          slotsRepositoryProvider.overrideWithValue(_NotFoundSlotsRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(slotDetailsProvider('missing-id').notifier)
          .loadInitial();

      final state = container.read(slotDetailsProvider('missing-id'));
      expect(state.slot.status, LoadableStatus.error);
      expect(state.slot.errorMessage, SlotDetailsMessages.notFound);
    });
  });

  group('SlotDetailsScreen', () {
    testWidgets('shows slot fields and enabled book CTA', (tester) async {
      final slot = testSlot(freeSeats: 3);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            slotsRepositoryProvider.overrideWithValue(
              _FakeSlotsRepository(slot: slot),
            ),
          ],
          child: MaterialApp(
            home: SlotDetailsScreen(slotId: slot.id),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text(SlotDetailsMessages.title), findsOneWidget);
      expect(find.text('Новичковый'), findsNWidgets(2));
      expect(find.textContaining('Инструктор:'), findsOneWidget);
      expect(find.textContaining('Места:'), findsOneWidget);
      expect(find.textContaining('Прокат:'), findsOneWidget);
      expect(find.textContaining('Цена:'), findsOneWidget);

      final bookButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, SlotDetailsMessages.book),
      );
      expect(bookButton.onPressed, isNotNull);
    });

    testWidgets('disables book CTA when no seats', (tester) async {
      final slot = testSlot(freeSeats: 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            slotsRepositoryProvider.overrideWithValue(
              _FakeSlotsRepository(slot: slot),
            ),
          ],
          child: MaterialApp(
            home: SlotDetailsScreen(slotId: slot.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(SlotDetailsMessages.noSeats), findsOneWidget);
      final bookButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, SlotDetailsMessages.book),
      );
      expect(bookButton.onPressed, isNull);
    });

    testWidgets('keeps book CTA enabled when rental is exhausted', (tester) async {
      final slot = testSlot(freeSeats: 2, freeRentalEquipment: 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            slotsRepositoryProvider.overrideWithValue(
              _FakeSlotsRepository(slot: slot),
            ),
          ],
          child: MaterialApp(
            home: SlotDetailsScreen(slotId: slot.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final bookButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, SlotDetailsMessages.book),
      );
      expect(bookButton.onPressed, isNotNull);
    });

    testWidgets('shows cancelled banner and disables CTA', (tester) async {
      final slot = testSlot(
        freeSeats: 3,
        status: SlotStatus.cancelled,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            slotsRepositoryProvider.overrideWithValue(
              _FakeSlotsRepository(slot: slot),
            ),
          ],
          child: MaterialApp(
            home: SlotDetailsScreen(slotId: slot.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(SlotDetailsMessages.cancelledBanner), findsOneWidget);
      final bookButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, SlotDetailsMessages.book),
      );
      expect(bookButton.onPressed, isNull);
    });
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

class _NotFoundSlotsRepository implements SlotsRepository {
  @override
  Future<SlotListResponse> listSlots(
    SlotFilters filters, {
    int offset = 0,
    int limit = 20,
  }) async {
    return const SlotListResponse(
      items: [],
      meta: PaginationMeta(limit: 20, offset: 0, total: 0),
    );
  }

  @override
  Future<SlotDto> getSlot(String slotId) {
    throw ApiException(
      statusCode: 404,
      error: const ApiErrorBody(code: 'not_found', message: 'Not found'),
    );
  }
}
