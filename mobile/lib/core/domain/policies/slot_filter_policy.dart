import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';

enum SlotListEmptyReason {
  none,
  noSlotsAvailable,
  noFilterMatches,
}

/// Состояние фильтров SCR-002 / BS-001 (LOGIC-005).
class SlotFilters {
  const SlotFilters({
    this.dateFrom,
    this.dateTo,
    this.zoneFormatTypes = const [],
    this.instructorIds = const [],
    this.onlyAvailable = false,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<ZoneFormatType> zoneFormatTypes;
  final List<String> instructorIds;
  final bool onlyAvailable;

  SlotFilters copy() {
    return SlotFilters(
      dateFrom: dateFrom,
      dateTo: dateTo,
      zoneFormatTypes: List<ZoneFormatType>.from(zoneFormatTypes),
      instructorIds: List<String>.from(instructorIds),
      onlyAvailable: onlyAvailable,
    );
  }

  SlotFilters copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<ZoneFormatType>? zoneFormatTypes,
    List<String>? instructorIds,
    bool? onlyAvailable,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return SlotFilters(
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      zoneFormatTypes: zoneFormatTypes ?? this.zoneFormatTypes,
      instructorIds: instructorIds ?? this.instructorIds,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SlotFilters &&
        other.dateFrom == dateFrom &&
        other.dateTo == dateTo &&
        _listEquals(other.zoneFormatTypes, zoneFormatTypes) &&
        _listEquals(other.instructorIds, instructorIds) &&
        other.onlyAvailable == onlyAvailable;
  }

  @override
  int get hashCode => Object.hash(
        dateFrom,
        dateTo,
        Object.hashAll(zoneFormatTypes),
        Object.hashAll(instructorIds),
        onlyAvailable,
      );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// Фильтрация, маппинг в query и группировка слотов (LOGIC-005).
class SlotFilterPolicy {
  const SlotFilterPolicy._();

  static const defaultPeriod = Duration(days: 7);

  static const SlotFilters defaults = SlotFilters();

  static bool isValidDateRange(SlotFilters filters) {
    final from = filters.dateFrom;
    final to = filters.dateTo;
    if (from == null || to == null) {
      return true;
    }
    return !from.isAfter(to);
  }

  static bool hasActiveFilters(SlotFilters filters) {
    return filters.dateFrom != null ||
        filters.dateTo != null ||
        filters.zoneFormatTypes.isNotEmpty ||
        filters.instructorIds.isNotEmpty ||
        filters.onlyAvailable;
  }

  static SlotListEmptyReason emptyReason({
    required int itemCount,
    required SlotFilters appliedFilters,
  }) {
    if (itemCount > 0) {
      return SlotListEmptyReason.none;
    }
    return hasActiveFilters(appliedFilters)
        ? SlotListEmptyReason.noFilterMatches
        : SlotListEmptyReason.noSlotsAvailable;
  }

  static ListSlotsQuery toListSlotsQuery(
    SlotFilters filters, {
    int limit = 20,
    int offset = 0,
  }) {
    return ListSlotsQuery(
      dateFrom: filters.dateFrom,
      dateTo: filters.dateTo,
      zoneFormatTypes: filters.zoneFormatTypes,
      instructorIds: filters.instructorIds,
      onlyAvailable: filters.onlyAvailable,
      limit: limit,
      offset: offset,
    );
  }

  static DateTime defaultPeriodEnd(DateTime now) {
    return now.add(defaultPeriod);
  }

  static List<SlotDto> sortByStartAt(List<SlotDto> slots) {
    final sorted = List<SlotDto>.of(slots);
    sorted.sort((a, b) => a.startAt.compareTo(b.startAt));
    return sorted;
  }

  static Map<DateTime, List<SlotDto>> groupByLocalDay(List<SlotDto> slots) {
    final grouped = <DateTime, List<SlotDto>>{};
    for (final slot in sortByStartAt(slots)) {
      final local = slot.startAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      grouped.putIfAbsent(day, () => []).add(slot);
    }
    return grouped;
  }
}
