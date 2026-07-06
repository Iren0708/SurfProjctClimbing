import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/api/vertical_api.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';

class SlotsRepository {
  const SlotsRepository(this._api);

  final VerticalApi _api;

  Future<SlotListResponse> listSlots(
    SlotFilters filters, {
    int offset = 0,
    int limit = 20,
  }) {
    final query = SlotFilterPolicy.toListSlotsQuery(
      filters,
      limit: limit,
      offset: offset,
    );
    return mapApiCall(() => _api.listSlots(query));
  }

  Future<SlotDto> getSlot(String slotId) {
    return mapApiCall(() => _api.getSlot(slotId));
  }
}
