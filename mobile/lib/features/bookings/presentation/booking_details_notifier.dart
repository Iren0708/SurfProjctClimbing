import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/bookings/data/bookings_repository_provider.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_details_messages.dart';

class BookingDetailsState {
  const BookingDetailsState({
    required this.booking,
    this.submitState = const ActionLoadableState.idle(),
    this.successSnack,
    this.sheetSnack,
  });

  final LoadableState<BookingDto> booking;
  final ActionLoadableState submitState;
  final String? successSnack;
  final String? sheetSnack;

  factory BookingDetailsState.initial() {
    return BookingDetailsState(
      booking: LoadableState<BookingDto>.loading(),
    );
  }

  BookingDetailsState copyWith({
    LoadableState<BookingDto>? booking,
    ActionLoadableState? submitState,
    String? successSnack,
    String? sheetSnack,
    bool clearSnacks = false,
  }) {
    return BookingDetailsState(
      booking: booking ?? this.booking,
      submitState: submitState ?? this.submitState,
      successSnack: clearSnacks ? null : (successSnack ?? this.successSnack),
      sheetSnack: clearSnacks ? null : (sheetSnack ?? this.sheetSnack),
    );
  }
}

class BookingDetailsNotifier
    extends AutoDisposeFamilyNotifier<BookingDetailsState, String> {
  @override
  BookingDetailsState build(String bookingId) {
    Future<void>.microtask(loadBooking);
    return BookingDetailsState.initial();
  }

  Future<void> loadBooking() async {
    state = BookingDetailsState.initial();
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final booking =
          await ref.read(bookingsRepositoryProvider).getBooking(arg);
      state = BookingDetailsState(
        booking: LoadableState.content(booking),
      );
    } on ApiException catch (error) {
      final message = error.statusCode == 404 || error.statusCode == 403
          ? BookingDetailsMessages.alreadyCancelled
          : null;
      state = BookingDetailsState(
        booking: LoadableState<BookingDto>.error(message: message),
      );
    } catch (_) {
      state = BookingDetailsState(
        booking: LoadableState<BookingDto>.error(),
      );
    }
  }

  Future<BookingDto?> cancelBooking() async {
    if (state.submitState.isSubmitting) {
      return null;
    }

    state = state.copyWith(
      submitState: const ActionLoadableState.submitting(),
      clearSnacks: true,
    );

    try {
      final booking =
          await ref.read(bookingsRepositoryProvider).cancelBooking(arg);
      final snack = switch (booking.status) {
        BookingStatus.cancelled => BookingDetailsMessages.earlyCancelSuccess,
        BookingStatus.lateCancel => BookingDetailsMessages.lateCancelSuccess,
        _ => BookingDetailsMessages.earlyCancelSuccess,
      };
      state = BookingDetailsState(
        booking: LoadableState.content(booking),
        successSnack: snack,
      );
      return booking;
    } on ApiException catch (error) {
      return _handleCancelError(error);
    } catch (_) {
      state = state.copyWith(
        submitState: const ActionLoadableState.idle(),
        sheetSnack: BookingDetailsMessages.cancelNetworkError,
      );
      return null;
    }
  }

  Future<BookingDto?> _handleCancelError(ApiException error) async {
    final code = error.error.code;
    if (code == 'already_cancelled') {
      await _fetch();
      state = state.copyWith(
        submitState: const ActionLoadableState.idle(),
        successSnack: BookingDetailsMessages.alreadyCancelledSnack,
      );
      return state.booking.data;
    }
    if (code == 'slot_started') {
      await _fetch();
      state = state.copyWith(
        submitState: const ActionLoadableState.idle(),
        successSnack: error.error.message.isNotEmpty
            ? error.error.message
            : BookingDetailsMessages.slotStarted,
      );
      return state.booking.data;
    }

    state = state.copyWith(
      submitState: const ActionLoadableState.idle(),
      sheetSnack: error.error.message.isNotEmpty
          ? error.error.message
          : BookingDetailsMessages.cancelGenericError,
    );
    return null;
  }

  void clearSnacks() {
    if (state.successSnack != null || state.sheetSnack != null) {
      state = state.copyWith(clearSnacks: true);
    }
  }
}

final bookingDetailsProvider = NotifierProvider.autoDispose
    .family<BookingDetailsNotifier, BookingDetailsState, String>(
  BookingDetailsNotifier.new,
);
