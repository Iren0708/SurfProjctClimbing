import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_details_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/booking_details_notifier.dart';

import '../../support/booking_test_data.dart';
import '../../support/fake_bookings_repository.dart';

void main() {
  const bookingId = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

  group('BookingDetailsNotifier', () {
    test('loads booking on init', () async {
      final repository = FakeBookingsRepository(
        getBookingResult: testBooking(id: bookingId),
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      final subscription = container.listen(
        bookingDetailsProvider(bookingId),
        (_, __) {},
      );
      addTearDown(subscription.close);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(bookingDetailsProvider(bookingId));
      expect(state.booking.status, LoadableStatus.content);
      expect(state.booking.data?.id, bookingId);
    });

    test('cancel sets success snack for early cancel', () async {
      final repository = FakeBookingsRepository(
        getBookingResult: testBooking(id: bookingId),
        cancelBookingResult: testBooking(
          id: bookingId,
          status: BookingStatus.cancelled,
        ),
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(bookingDetailsProvider(bookingId).notifier).loadBooking();
      await Future<void>.delayed(Duration.zero);

      await container
          .read(bookingDetailsProvider(bookingId).notifier)
          .cancelBooking();

      final state = container.read(bookingDetailsProvider(bookingId));
      expect(state.successSnack, BookingDetailsMessages.earlyCancelSuccess);
      expect(repository.lastCancelledBookingId, bookingId);
    });

    test('already cancelled error refreshes booking and shows snack', () async {
      final repository = _AlreadyCancelledBookingsRepository(bookingId);
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(bookingDetailsProvider(bookingId).notifier).loadBooking();
      await Future<void>.delayed(Duration.zero);

      await container
          .read(bookingDetailsProvider(bookingId).notifier)
          .cancelBooking();

      final state = container.read(bookingDetailsProvider(bookingId));
      expect(state.successSnack, BookingDetailsMessages.alreadyCancelledSnack);
      expect(state.booking.data?.status, BookingStatus.cancelled);
    });
  });
}

ProviderContainer _createContainer(FakeBookingsRepository repository) {
  return ProviderContainer(
    overrides: [
      bookingsRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _AlreadyCancelledBookingsRepository extends FakeBookingsRepository {
  _AlreadyCancelledBookingsRepository(this.bookingId);

  final String bookingId;
  var cancelAttempts = 0;

  @override
  Future<BookingDto> getBooking(String id) async {
    return testBooking(
      id: bookingId,
      status: cancelAttempts > 0 ? BookingStatus.cancelled : BookingStatus.active,
    );
  }

  @override
  Future<BookingDto> cancelBooking(String id) async {
    cancelAttempts++;
    throw ApiException(
      statusCode: 409,
      error: const ApiErrorBody(
        code: 'already_cancelled',
        message: 'Already cancelled',
      ),
    );
  }
}
