import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_filters_notifier.dart';
import 'package:vertical_mobile/features/slots/presentation/slots_list_state.dart';

class SlotsListNotifier extends Notifier<SlotsListState> {
  static const _pageSize = 20;

  @override
  SlotsListState build() {
    final filters = ref.watch(slotFiltersProvider);
    ref.listen<SlotFilters>(slotFiltersProvider, (previous, next) {
      if (previous != next) {
        loadInitial();
      }
    });
    Future<void>.microtask(loadInitial);
    return SlotsListState.initial(filters);
  }

  Future<void> loadInitial() async {
    final filters = ref.read(slotFiltersProvider);
    state = SlotsListState.initial(filters);
    await _fetchPage(offset: 0, isRefresh: false);
  }

  Future<void> refresh() async {
    final current = state.slots;
    if (current.hasContent) {
      state = state.copyWith(
        slots: LoadableState.content(
          current.data!,
          isRefreshing: true,
        ),
        clearRefreshError: true,
      );
    } else if (current.status == LoadableStatus.empty) {
      state = state.copyWith(
        slots: LoadableState<List<SlotDto>>.empty(isRefreshing: true),
        clearRefreshError: true,
      );
    }
    await _fetchPage(offset: 0, isRefresh: true);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoadingMore) {
      return;
    }
    final items = state.slots.data;
    if (items == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    try {
      final response = await ref.read(slotsRepositoryProvider).listSlots(
            state.filters,
            offset: items.length,
            limit: _pageSize,
          );
      final merged = [...items, ...response.items];
      state = state.copyWith(
        slots: LoadableState.content(merged),
        meta: response.meta,
        cachedItems: merged,
        isLoadingMore: false,
        showStaleBanner: false,
      );
    } on ApiException {
      state = state.copyWith(isLoadingMore: false);
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void clearRefreshError() {
    if (state.refreshError != null) {
      state = state.copyWith(clearRefreshError: true);
    }
  }

  Future<void> _fetchPage({
    required int offset,
    required bool isRefresh,
  }) async {
    final filters = ref.read(slotFiltersProvider);
    try {
      final response = await ref.read(slotsRepositoryProvider).listSlots(
            filters,
            offset: offset,
            limit: _pageSize,
          );

      final loadable = response.items.isEmpty
          ? LoadableState<List<SlotDto>>.empty()
          : LoadableState.content(response.items);

      state = SlotsListState(
        slots: loadable,
        filters: filters,
        meta: response.meta,
        cachedItems: response.items,
        showStaleBanner: false,
      );
    } on ApiException catch (_) {
      _handleError(isRefresh: isRefresh);
    } catch (_) {
      _handleError(isRefresh: isRefresh);
    }
  }

  void _handleError({required bool isRefresh}) {
    final cached = state.cachedItems;
    if (isRefresh && cached.isNotEmpty) {
      state = state.copyWith(
        slots: LoadableState.content(cached),
        refreshError: LoadableMessages.refreshError,
      );
      return;
    }

    if (cached.isNotEmpty) {
      state = state.copyWith(
        slots: LoadableState.content(cached),
        showStaleBanner: true,
      );
      return;
    }

    state = state.copyWith(
      slots: LoadableState<List<SlotDto>>.error(),
    );
  }
}

final slotsListProvider =
    NotifierProvider<SlotsListNotifier, SlotsListState>(
  SlotsListNotifier.new,
);
