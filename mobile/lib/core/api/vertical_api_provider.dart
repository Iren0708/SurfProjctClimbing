import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/dio_provider.dart';
import 'package:vertical_mobile/core/api/vertical_api.dart';
import 'package:vertical_mobile/core/api/vertical_api_client.dart';

final verticalApiProvider = Provider<VerticalApi>(
  (ref) => VerticalApiClient(ref.watch(dioProvider)),
);
