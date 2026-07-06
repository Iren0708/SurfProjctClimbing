import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_filters_notifier.dart';
import 'package:vertical_mobile/features/slots/presentation/slots_list_notifier.dart';

import '../../support/slot_test_data.dart';

void main() {
  group('SlotsListNotifier', () {
    test('loads slots on init', () async {
      final container = _createContainer(_FakeSlotsRepository());

      await container.read(slotsListProvider.notifier).loadInitial();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(slotsListProvider);
      expect(state.slots.status, LoadableStatus.content);
      expect(state.slots.data, hasLength(2));
    });

    test('shows empty state when API returns no items', () async {
      final container = _createContainer(_FakeSlotsRepository(empty: true));

      await container.read(slotsListProvider.notifier).loadInitial();

      final state = container.read(slotsListProvider);
      expect(state.slots.status, LoadableStatus.empty);
    });

    test('reloads list when filters change', () async {
      final repository = _CountingSlotsRepository();
      final container = _createContainer(repository);

      await container.read(slotsListProvider.notifier).loadInitial();
      await Future<void>.delayed(Duration.zero);

      final callsAfterLoad = repository.callCount;

      container
          .read(slotFiltersProvider.notifier)
          .apply(const SlotFilters(onlyAvailable: true));
      await Future<void>.delayed(Duration.zero);

      expect(repository.callCount, greaterThan(callsAfterLoad));
      expect(container.read(slotsListProvider).filters.onlyAvailable, isTrue);
    });
  });
}

ProviderContainer _createContainer(SlotsRepository repository) {
  return ProviderContainer(
    overrides: [
      slotsRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _FakeSlotsRepository implements SlotsRepository {
  _FakeSlotsRepository({this.empty = false});

  final bool empty;

  @override
  Future<SlotListResponse> listSlots(
    SlotFilters filters, {
    int offset = 0,
    int limit = 20,
  }) async {
    if (empty) {
      return const SlotListResponse(
        items: [],
        meta: PaginationMeta(limit: 20, offset: 0, total: 0),
      );
    }

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

class _CountingSlotsRepository implements SlotsRepository {
  int callCount = 0;

  @override
  Future<SlotListResponse> listSlots(
    SlotFilters filters, {
    int offset = 0,
    int limit = 20,
  }) async {
    callCount++;
    return SlotListResponse(
      items: [testSlot()],
      meta: const PaginationMeta(limit: 20, offset: 0, total: 1),
    );
  }

  @override
  Future<SlotDto> getSlot(String slotId) async => testSlot(id: slotId);
}
