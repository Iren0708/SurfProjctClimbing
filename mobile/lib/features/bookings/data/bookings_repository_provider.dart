import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/vertical_api_provider.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository.dart';

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => BookingsRepository(ref.watch(verticalApiProvider)),
);
