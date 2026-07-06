import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/app/vertical_app.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';

import 'support/in_memory_token_storage.dart';
import 'support/slot_test_data.dart';

void main() {
  testWidgets('redirects to phone step when session is missing', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
        ],
        child: const VerticalApp(),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Вертикаль'), findsOneWidget);
    expect(find.text('Получить код'), findsOneWidget);
    expect(find.textContaining('Без пароля'), findsOneWidget);
  });

  testWidgets('redirects to main shell when refresh token exists', (tester) async {
    final storage = InMemoryTokenStorage()
      ..refreshToken = 'refresh-token'
      ..accessToken = 'access-token';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(storage),
          slotsRepositoryProvider.overrideWithValue(_WidgetTestSlotsRepository()),
        ],
        child: const VerticalApp(),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Тренировки'), findsWidgets);
    expect(find.text('Новичковый'), findsWidgets);
  });
}

class _WidgetTestSlotsRepository implements SlotsRepository {
  @override
  Future<SlotListResponse> listSlots(
    SlotFilters filters, {
    int offset = 0,
    int limit = 20,
  }) async {
    return SlotListResponse(
      items: [testSlot()],
      meta: const PaginationMeta(limit: 20, offset: 0, total: 1),
    );
  }

  @override
  Future<SlotDto> getSlot(String slotId) async => testSlot(id: slotId);
}
