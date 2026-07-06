import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';

class SlotDetailsState {
  const SlotDetailsState({
    required this.slot,
    this.refreshError,
    this.cachedSlot,
  });

  final LoadableState<SlotDto> slot;
  final String? refreshError;
  final SlotDto? cachedSlot;

  factory SlotDetailsState.initial() {
    return SlotDetailsState(
      slot: LoadableState<SlotDto>.loading(),
    );
  }

  SlotDetailsState copyWith({
    LoadableState<SlotDto>? slot,
    String? refreshError,
    SlotDto? cachedSlot,
    bool clearRefreshError = false,
  }) {
    return SlotDetailsState(
      slot: slot ?? this.slot,
      refreshError: clearRefreshError ? null : (refreshError ?? this.refreshError),
      cachedSlot: cachedSlot ?? this.cachedSlot,
    );
  }
}
