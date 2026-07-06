import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/vertical_api_provider.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';

final slotsRepositoryProvider = Provider<SlotsRepository>(
  (ref) => SlotsRepository(ref.watch(verticalApiProvider)),
);
