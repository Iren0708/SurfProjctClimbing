import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';
import 'package:vertical_mobile/features/slots/presentation/slots_screen.dart';

import '../../support/slot_test_data.dart';

void main() {
  testWidgets('shows grouped slot cards in content state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          slotsRepositoryProvider.overrideWithValue(_FakeSlotsRepository()),
        ],
        child: const MaterialApp(home: SlotsScreen()),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Тренировки'), findsOneWidget);
    expect(find.text('Новичковый'), findsWidgets);
    expect(find.text('Мест нет'), findsOneWidget);
  });
}

class _FakeSlotsRepository implements SlotsRepository {
  @override
  Future<SlotListResponse> listSlots(
    SlotFilters filters, {
    int offset = 0,
    int limit = 20,
  }) async {
    return SlotListResponse(
      items: [
        testSlot(startAt: DateTime.utc(2026, 7, 10, 10)),
        testSlot(
          id: '22222222-2222-2222-2222-222222222222',
          startAt: DateTime.utc(2026, 7, 10, 18),
          freeSeats: 0,
        ),
      ],
      meta: const PaginationMeta(limit: 20, offset: 0, total: 2),
    );
  }

  @override
  Future<SlotDto> getSlot(String slotId) async => testSlot(id: slotId);
}
