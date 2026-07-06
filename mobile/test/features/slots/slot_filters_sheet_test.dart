import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/features/slots/presentation/filters/instructors_catalog_provider.dart';
import 'package:vertical_mobile/features/slots/presentation/filters/slot_filters_sheet.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_filters_notifier.dart';

void main() {
  testWidgets('apply writes draft filters to slotFiltersProvider', (tester) async {
    const instructors = [
      InstructorDto(
        id: '33333333-3333-3333-3333-333333333333',
        name: 'Анна',
      ),
    ];

    late ProviderContainer container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container = ProviderContainer(
          overrides: [
            instructorsCatalogProvider.overrideWith(
              (ref) async => instructors,
            ),
          ],
        ),
        child: const MaterialApp(
          home: Scaffold(
            body: SlotFiltersSheet(
              appliedFilters: SlotFilterPolicy.defaults,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Только со свободными местами'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();

    expect(container.read(slotFiltersProvider).onlyAvailable, isTrue);
  });

  testWidgets('apply is disabled for inverted date range', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          instructorsCatalogProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SlotFiltersSheet(
              appliedFilters: SlotFilters(
                dateFrom: DateTime(2026, 7, 10),
                dateTo: DateTime(2026, 7, 5),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final applyButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Применить'),
    );
    expect(applyButton.onPressed, isNull);
    expect(find.text('Конец периода не может быть раньше начала'), findsOneWidget);
  });
}
