import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';

class SlotsListState {
  const SlotsListState({
    required this.slots,
    required this.filters,
    this.meta,
    this.cachedItems = const [],
    this.showStaleBanner = false,
    this.isLoadingMore = false,
    this.refreshError,
  });

  factory SlotsListState.initial(SlotFilters filters) {
    return SlotsListState(
      slots: LoadableState<List<SlotDto>>.loading(),
      filters: filters,
    );
  }

  final LoadableState<List<SlotDto>> slots;
  final SlotFilters filters;
  final PaginationMeta? meta;
  final List<SlotDto> cachedItems;
  final bool showStaleBanner;
  final bool isLoadingMore;
  final String? refreshError;

  bool get canLoadMore {
    final meta = this.meta;
    final items = slots.data;
    if (meta == null || items == null) {
      return false;
    }
    return items.length < meta.total;
  }

  SlotsListState copyWith({
    LoadableState<List<SlotDto>>? slots,
    SlotFilters? filters,
    PaginationMeta? meta,
    List<SlotDto>? cachedItems,
    bool? showStaleBanner,
    bool? isLoadingMore,
    String? refreshError,
    bool clearRefreshError = false,
  }) {
    return SlotsListState(
      slots: slots ?? this.slots,
      filters: filters ?? this.filters,
      meta: meta ?? this.meta,
      cachedItems: cachedItems ?? this.cachedItems,
      showStaleBanner: showStaleBanner ?? this.showStaleBanner,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      refreshError:
          clearRefreshError ? null : (refreshError ?? this.refreshError),
    );
  }
}
