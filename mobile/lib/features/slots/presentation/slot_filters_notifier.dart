import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';

class SlotFiltersNotifier extends Notifier<SlotFilters> {
  @override
  SlotFilters build() => SlotFilterPolicy.defaults;

  void apply(SlotFilters filters) {
    state = filters;
  }

  void reset() {
    state = SlotFilterPolicy.defaults;
  }
}

final slotFiltersProvider =
    NotifierProvider<SlotFiltersNotifier, SlotFilters>(
  SlotFiltersNotifier.new,
);
