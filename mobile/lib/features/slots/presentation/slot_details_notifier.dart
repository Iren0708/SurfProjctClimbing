import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/slots/data/slots_repository_provider.dart';
import 'package:vertical_mobile/features/slots/domain/slot_details_messages.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_details_state.dart';

class SlotDetailsNotifier
    extends AutoDisposeFamilyNotifier<SlotDetailsState, String> {
  @override
  SlotDetailsState build(String slotId) {
    Future<void>.microtask(loadInitial);
    return SlotDetailsState.initial();
  }

  Future<void> loadInitial() async {
    state = SlotDetailsState.initial();
    await _fetch(isRefresh: false);
  }

  Future<void> refresh() async {
    final current = state.slot;
    if (current.hasContent) {
      state = state.copyWith(
        slot: LoadableState.content(current.data!, isRefreshing: true),
        clearRefreshError: true,
      );
    }
    await _fetch(isRefresh: true);
  }

  void clearRefreshError() {
    if (state.refreshError != null) {
      state = state.copyWith(clearRefreshError: true);
    }
  }

  Future<void> _fetch({required bool isRefresh}) async {
    final slotId = arg;
    try {
      final slot = await ref.read(slotsRepositoryProvider).getSlot(slotId);
      state = SlotDetailsState(
        slot: LoadableState.content(slot),
        cachedSlot: slot,
      );
    } on ApiException catch (error) {
      _handleError(error: error, isRefresh: isRefresh);
    } catch (_) {
      _handleError(isRefresh: isRefresh);
    }
  }

  void _handleError({ApiException? error, required bool isRefresh}) {
    final cached = state.cachedSlot;
    if (isRefresh && cached != null) {
      state = state.copyWith(
        slot: LoadableState.content(cached),
        refreshError: LoadableMessages.refreshError,
      );
      return;
    }

    if (error?.statusCode == 404) {
      state = SlotDetailsState(
        slot: LoadableState<SlotDto>.error(
          message: SlotDetailsMessages.notFound,
        ),
        cachedSlot: cached,
      );
      return;
    }

    state = SlotDetailsState(
      slot: LoadableState<SlotDto>.error(),
      cachedSlot: cached,
    );
  }
}

final slotDetailsProvider = NotifierProvider.autoDispose
    .family<SlotDetailsNotifier, SlotDetailsState, String>(
  SlotDetailsNotifier.new,
);
