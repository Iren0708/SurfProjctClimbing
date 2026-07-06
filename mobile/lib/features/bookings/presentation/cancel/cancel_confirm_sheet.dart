import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/domain/policies/cancellation_policy.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_details_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/booking_details_notifier.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';

Future<bool?> showCancelConfirmSheet({
  required BuildContext context,
  required String bookingId,
  required BookingDto booking,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    showDragHandle: true,
    builder: (context) {
      return CancelConfirmSheet(
        bookingId: bookingId,
        booking: booking,
      );
    },
  );
}

class CancelConfirmSheet extends ConsumerWidget {
  const CancelConfirmSheet({
    super.key,
    required this.bookingId,
    required this.booking,
  });

  final String bookingId;
  final BookingDto booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(bookingDetailsProvider(bookingId));
    final notifier = ref.read(bookingDetailsProvider(bookingId).notifier);

    ref.listen(bookingDetailsProvider(bookingId), (previous, next) {
      if (next.sheetSnack != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.sheetSnack!)),
        );
        notifier.clearSnacks();
      }
    });

    final tokens = context.verticalTokens;
    final slot = booking.slot;
    final preview = slot == null
        ? CancelPreviewType.early
        : CancellationPolicy.previewType(DateTime.now(), slot.startAt);
    final hint = preview == CancelPreviewType.early
        ? BookingDetailsMessages.earlyCancelHint
        : BookingDetailsMessages.lateCancelHint;
    final isSubmitting = detailsState.submitState.isSubmitting;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        0,
        tokens.screenPadding,
        tokens.screenPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            BookingDetailsMessages.cancelSheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spacingLg),
          if (slot != null) ...[
            Text(SlotFormatters.formatDateTimeHeader(slot.startAt)),
            SizedBox(height: tokens.spacingXs),
            Text(slot.zoneFormat.name),
            SizedBox(height: tokens.spacingLg),
          ],
          Text(hint),
          SizedBox(height: tokens.spacingXl),
          ActionLoadableButton(
            label: BookingDetailsMessages.confirmCancel,
            state: detailsState.submitState,
            onPressed: isSubmitting
                ? null
                : () async {
                    final result = await notifier.cancelBooking();
                    if (context.mounted && result != null) {
                      Navigator.of(context).pop(true);
                    }
                  },
          ),
          SizedBox(height: tokens.spacingSm),
          OutlinedButton(
            onPressed: isSubmitting
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text(BookingDetailsMessages.keepBooking),
          ),
        ],
      ),
    );
  }
}
