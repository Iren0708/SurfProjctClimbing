import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';

import '../../../support/slot_test_data.dart';

void main() {
  group('SlotFilterPolicy', () {
    test('default filters are not active', () {
      expect(SlotFilterPolicy.hasActiveFilters(SlotFilterPolicy.defaults), isFalse);
    });

    test('only_available marks filters as active', () {
      const filters = SlotFilters(onlyAvailable: true);
      expect(SlotFilterPolicy.hasActiveFilters(filters), isTrue);
    });

    test('isValidDateRange allows open-ended dates', () {
      expect(
        SlotFilterPolicy.isValidDateRange(const SlotFilters()),
        isTrue,
      );
    });

    test('isValidDateRange rejects inverted range', () {
      final filters = SlotFilters(
        dateFrom: DateTime(2026, 7, 10),
        dateTo: DateTime(2026, 7, 5),
      );
      expect(SlotFilterPolicy.isValidDateRange(filters), isFalse);
    });

    test('maps filters to ListSlotsQuery', () {
      final from = DateTime.utc(2026, 7, 6);
      final to = DateTime.utc(2026, 7, 13);
      final filters = SlotFilters(
        dateFrom: from,
        dateTo: to,
        zoneFormatTypes: const [ZoneFormatType.novice, ZoneFormatType.experienced],
        instructorIds: const ['33333333-3333-3333-3333-333333333333'],
        onlyAvailable: true,
      );

      final query = SlotFilterPolicy.toListSlotsQuery(filters, limit: 10);
      final params = query.toQueryParameters();

      expect(params['date_from'], from.toUtc().toIso8601String());
      expect(params['date_to'], to.toUtc().toIso8601String());
      expect(params['zone_format_type'], ['novice', 'experienced']);
      expect(params['instructor_id'], ['33333333-3333-3333-3333-333333333333']);
      expect(params['only_available'], isTrue);
      expect(params['limit'], 10);
    });

    test('empty list with default filters means no slots available', () {
      expect(
        SlotFilterPolicy.emptyReason(
          itemCount: 0,
          appliedFilters: SlotFilterPolicy.defaults,
        ),
        SlotListEmptyReason.noSlotsAvailable,
      );
    });

    test('empty list with active filters means no filter matches', () {
      expect(
        SlotFilterPolicy.emptyReason(
          itemCount: 0,
          appliedFilters: const SlotFilters(onlyAvailable: true),
        ),
        SlotListEmptyReason.noFilterMatches,
      );
    });

    test('default period end is 7 days from now', () {
      final now = DateTime.utc(2026, 7, 6, 12);
      expect(
        SlotFilterPolicy.defaultPeriodEnd(now),
        DateTime.utc(2026, 7, 13, 12),
      );
    });

    test('sorts slots by start_at ascending', () {
      final later = testSlot(startAt: DateTime.utc(2026, 7, 10, 12));
      final earlier = testSlot(startAt: DateTime.utc(2026, 7, 10, 10));

      final sorted = SlotFilterPolicy.sortByStartAt([later, earlier]);

      expect(sorted.first.startAt, earlier.startAt);
      expect(sorted.last.startAt, later.startAt);
    });

    test('groups slots by local calendar day', () {
      final morning = testSlot(startAt: DateTime.utc(2026, 7, 10, 6));
      final evening = testSlot(startAt: DateTime.utc(2026, 7, 10, 18));
      final nextDay = testSlot(startAt: DateTime.utc(2026, 7, 11, 6));

      final grouped = SlotFilterPolicy.groupByLocalDay([
        evening,
        nextDay,
        morning,
      ]);

      expect(grouped.length, 2);
      expect(grouped.values.first.length, 2);
      expect(grouped.values.last.length, 1);
    });
  });
}
