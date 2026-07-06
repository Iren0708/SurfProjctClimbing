import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/vertical_api_provider.dart';

final instructorsCatalogProvider =
    FutureProvider.autoDispose<List<InstructorDto>>((ref) {
  return mapApiCall(() async {
    final response = await ref.watch(verticalApiProvider).listInstructors();
    return response.items;
  });
});
