import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/vertical_api_provider.dart';
import 'package:vertical_mobile/features/profile/data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(verticalApiProvider)),
);
