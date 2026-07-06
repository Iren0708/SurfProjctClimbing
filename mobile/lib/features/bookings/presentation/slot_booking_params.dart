import 'package:flutter/foundation.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';

@immutable
class SlotBookingParams {
  const SlotBookingParams({
    required this.slotId,
    this.initialSlot,
  });

  final String slotId;
  final SlotDto? initialSlot;

  @override
  bool operator ==(Object other) {
    return other is SlotBookingParams &&
        other.slotId == slotId &&
        other.initialSlot == initialSlot;
  }

  @override
  int get hashCode => Object.hash(slotId, initialSlot);
}
