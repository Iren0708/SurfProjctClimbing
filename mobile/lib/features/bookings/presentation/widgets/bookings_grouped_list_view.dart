import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/domain/policies/booking_list_policy.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_list_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_status_labels.dart';
import 'package:vertical_mobile/features/bookings/presentation/widgets/booking_card.dart';

class BookingsGroupedListView extends StatelessWidget {
  const BookingsGroupedListView({
    super.key,
    required this.bookings,
    required this.onBookingTap,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.canLoadMore,
    this.now,
  });

  final List<BookingSummaryDto> bookings;
  final ValueChanged<BookingSummaryDto> onBookingTap;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool canLoadMore;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final grouped = BookingListPolicy.groupBySection(bookings, now: now);
    final entries = <_BookingsListEntry>[];

    final upcoming = grouped[BookingListSection.upcoming]!;
    if (upcoming.isNotEmpty) {
      entries.add(_BookingsListEntry.header(BookingListMessages.upcomingSection));
      for (final booking in upcoming) {
        entries.add(_BookingsListEntry.booking(booking));
      }
    }

    final past = grouped[BookingListSection.pastAndCancelled]!;
    if (past.isNotEmpty) {
      entries.add(_BookingsListEntry.header(BookingListMessages.pastSection));
      for (final booking in past) {
        entries.add(_BookingsListEntry.booking(booking));
      }
    }

    if (canLoadMore) {
      entries.add(_BookingsListEntry.loader());
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: tokens.spacingLg),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.isLoader) {
          if (!isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) => onLoadMore());
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (entry.header != null) {
          return BookingSectionHeader(title: entry.header!);
        }
        final booking = entry.booking!;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.screenPadding,
            vertical: tokens.spacingXs,
          ),
          child: BookingCard(
            booking: booking,
            now: now,
            onTap: () => onBookingTap(booking),
          ),
        );
      },
    );
  }
}

class _BookingsListEntry {
  _BookingsListEntry.header(this.header)
      : booking = null,
        isLoader = false;

  _BookingsListEntry.booking(this.booking)
      : header = null,
        isLoader = false;

  _BookingsListEntry.loader()
      : header = null,
        booking = null,
        isLoader = true;

  final String? header;
  final BookingSummaryDto? booking;
  final bool isLoader;
}

String equipmentShortLabel(Equipment equipment) {
  return switch (equipment) {
    Equipment.own => 'Своё',
    Equipment.rental => 'Прокатное',
  };
}

String equipmentFullLabel(Equipment equipment) {
  return switch (equipment) {
    Equipment.own => BookingFlowMessages.ownEquipment,
    Equipment.rental => BookingFlowMessages.rentalEquipment,
  };
}

String bookingStatusLabel(BookingSummaryDto booking, {DateTime? now}) {
  return BookingStatusLabels.forBooking(
    status: booking.status,
    slotStartAt: booking.slot?.startAt,
    now: now ?? DateTime.now(),
  );
}
