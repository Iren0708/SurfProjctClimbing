import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/presentation/bookings_list_notifier.dart';

import '../../support/booking_test_data.dart';
import '../../support/fake_bookings_repository.dart';

void main() {
  group('BookingsListNotifier', () {
    test('loads bookings on init', () async {
      final repository = FakeBookingsRepository(
        listItems: [
          testBookingSummary(id: 'one'),
          testBookingSummary(id: 'two'),
        ],
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(bookingsListProvider.notifier).loadInitial();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(bookingsListProvider);
      expect(state.bookings.status, LoadableStatus.content);
      expect(state.bookings.data, hasLength(2));
    });

    test('shows empty state when API returns no items', () async {
      final repository = FakeBookingsRepository(listItems: []);
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await container.read(bookingsListProvider.notifier).loadInitial();

      expect(
        container.read(bookingsListProvider).bookings.status,
        LoadableStatus.empty,
      );
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
