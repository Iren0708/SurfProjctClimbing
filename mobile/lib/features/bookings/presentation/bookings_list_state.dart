import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';

class BookingsListState {
  const BookingsListState({
    required this.bookings,
    this.meta,
    this.cachedItems = const [],
    this.isLoadingMore = false,
    this.showStaleBanner = false,
    this.refreshError,
  });

  final LoadableState<List<BookingSummaryDto>> bookings;
  final PaginationMeta? meta;
  final List<BookingSummaryDto> cachedItems;
  final bool isLoadingMore;
  final bool showStaleBanner;
  final String? refreshError;

  factory BookingsListState.initial() {
    return BookingsListState(
      bookings: LoadableState<List<BookingSummaryDto>>.loading(),
    );
  }

  bool get canLoadMore {
    final meta = this.meta;
    final items = bookings.data;
    if (meta == null || items == null) {
      return false;
    }
    return items.length < meta.total;
  }

  BookingsListState copyWith({
    LoadableState<List<BookingSummaryDto>>? bookings,
    PaginationMeta? meta,
    List<BookingSummaryDto>? cachedItems,
    bool? isLoadingMore,
    bool? showStaleBanner,
    String? refreshError,
    bool clearRefreshError = false,
  }) {
    return BookingsListState(
      bookings: bookings ?? this.bookings,
      meta: meta ?? this.meta,
      cachedItems: cachedItems ?? this.cachedItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      showStaleBanner: showStaleBanner ?? this.showStaleBanner,
      refreshError:
          clearRefreshError ? null : (refreshError ?? this.refreshError),
    );
  }
}
