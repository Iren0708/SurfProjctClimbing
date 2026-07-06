import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_placeholders.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_list_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/bookings_list_notifier.dart';
import 'package:vertical_mobile/features/bookings/presentation/widgets/bookings_grouped_list_view.dart';
import 'package:vertical_mobile/features/slots/domain/slot_list_messages.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(bookingsListProvider);
    final notifier = ref.read(bookingsListProvider.notifier);

    ref.listen(bookingsListProvider, (previous, next) {
      if (next.refreshError != null && context.mounted) {
        showRefreshErrorSnackBar(context);
        notifier.clearRefreshError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(BookingListMessages.title),
      ),
      body: Column(
        children: [
          if (listState.showStaleBanner)
            const MaterialBanner(
              content: Text(SlotListMessages.staleCacheBanner),
              actions: [SizedBox.shrink()],
            ),
          Expanded(
            child: StateContainer<List<BookingSummaryDto>>(
              state: listState.bookings,
              onRetry: notifier.loadInitial,
              emptyBuilder: (_) => _EmptyBookings(
                onFindSlot: () => context.go(AppRoutes.slots),
                onRefresh: notifier.refresh,
              ),
              contentBuilder: (_, bookings) => RefreshIndicator(
                onRefresh: notifier.refresh,
                child: Stack(
                  children: [
                    BookingsGroupedListView(
                      bookings: bookings,
                      onBookingTap: (booking) {
                        context.push(AppRoutes.bookingDetailsPath(booking.id));
                      },
                      onLoadMore: notifier.loadMore,
                      isLoadingMore: listState.isLoadingMore,
                      canLoadMore: listState.canLoadMore,
                    ),
                    if (listState.bookings.isRefreshing)
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({
    required this.onFindSlot,
    required this.onRefresh,
  });

  final VoidCallback onFindSlot;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: LoadableEmptyView(
              title: BookingListMessages.emptyTitle,
              actionLabel: BookingListMessages.findSlotAction,
              onAction: onFindSlot,
            ),
          ),
        ],
      ),
    );
  }
}
