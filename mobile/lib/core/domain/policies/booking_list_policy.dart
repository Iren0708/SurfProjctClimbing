import 'package:vertical_mobile/core/api/models/booking_models.dart';

enum BookingListSection {
  upcoming,
  pastAndCancelled,
}

/// Группировка броней SCR-005.
class BookingListPolicy {
  const BookingListPolicy._();

  static bool isUpcoming(BookingSummaryDto booking, DateTime now) {
    final slot = booking.slot;
    if (slot == null) {
      return booking.status == BookingStatus.active;
    }
    return booking.status == BookingStatus.active && slot.startAt.isAfter(now);
  }

  static Map<BookingListSection, List<BookingSummaryDto>> groupBySection(
    List<BookingSummaryDto> items, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final upcoming = <BookingSummaryDto>[];
    final past = <BookingSummaryDto>[];

    for (final item in items) {
      if (isUpcoming(item, reference)) {
        upcoming.add(item);
      } else {
        past.add(item);
      }
    }

    return {
      BookingListSection.upcoming: upcoming,
      BookingListSection.pastAndCancelled: past,
    };
  }
}
