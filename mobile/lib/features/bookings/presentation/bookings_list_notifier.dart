import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/presentation/bookings_list_state.dart';

class BookingsListNotifier extends Notifier<BookingsListState> {
  static const _pageSize = 20;

  @override
  BookingsListState build() {
    Future<void>.microtask(loadInitial);
    return BookingsListState.initial();
  }

  Future<void> loadInitial() async {
    state = BookingsListState.initial();
    await _fetchPage(offset: 0, isRefresh: false);
  }

  Future<void> refresh() async {
    final current = state.bookings;
    if (current.hasContent) {
      state = state.copyWith(
        bookings: LoadableState.content(
          current.data!,
          isRefreshing: true,
        ),
        clearRefreshError: true,
      );
    } else if (current.status == LoadableStatus.empty) {
      state = state.copyWith(
        bookings: LoadableState<List<BookingSummaryDto>>.empty(
          isRefreshing: true,
        ),
        clearRefreshError: true,
      );
    }
    await _fetchPage(offset: 0, isRefresh: true);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoadingMore) {
      return;
    }
    final items = state.bookings.data;
    if (items == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);
    try {
      final response = await ref.read(bookingsRepositoryProvider).listBookings(
            offset: items.length,
            limit: _pageSize,
          );
      final merged = [...items, ...response.items];
      state = state.copyWith(
        bookings: LoadableState.content(merged),
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
    try {
      final response = await ref.read(bookingsRepositoryProvider).listBookings(
            offset: offset,
            limit: _pageSize,
          );

      final loadable = response.items.isEmpty
          ? LoadableState<List<BookingSummaryDto>>.empty()
          : LoadableState.content(response.items);

      state = BookingsListState(
        bookings: loadable,
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
        bookings: LoadableState.content(cached),
        refreshError: LoadableMessages.refreshError,
      );
      return;
    }

    if (cached.isNotEmpty) {
      state = state.copyWith(
        bookings: LoadableState.content(cached),
        showStaleBanner: true,
      );
      return;
    }

    state = state.copyWith(
      bookings: LoadableState<List<BookingSummaryDto>>.error(),
    );
  }
}

final bookingsListProvider =
    NotifierProvider<BookingsListNotifier, BookingsListState>(
  BookingsListNotifier.new,
);
