import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/domain/policies/booking_price_calculator.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_success_messages.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';

/// Шторка BS-002 после успешного createBooking.
Future<BookingSuccessAction> showBookingSuccessSheet({
  required BuildContext context,
  required CreateBookingResponse booking,
}) async {
  final action = await showModalBottomSheet<BookingSuccessAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    builder: (context) {
      return BookingSuccessSheet(booking: booking);
    },
  );
  return action ?? BookingSuccessAction.done;
}

class BookingSuccessSheet extends StatelessWidget {
  const BookingSuccessSheet({
    super.key,
    required this.booking,
  });

  final CreateBookingResponse booking;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);
    final slot = booking.slot;
    final equipmentLabel = booking.equipment == Equipment.own
        ? BookingFlowMessages.ownEquipment
        : BookingFlowMessages.rentalEquipment;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          0,
          tokens.screenPadding,
          tokens.screenPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: tokens.spacingMd),
                Text(
                  BookingSuccessMessages.title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.spacingXl),
                if (slot != null) ...[
                  _SummaryRow(
                    icon: Icons.calendar_today_outlined,
                    text: SlotFormatters.formatDateTimeHeader(slot.startAt),
                  ),
                  SizedBox(height: tokens.spacingSm),
                  _SummaryRow(
                    icon: Icons.fitness_center_outlined,
                    text: slot.zoneFormat.name,
                  ),
                  SizedBox(height: tokens.spacingSm),
                  _SummaryRow(
                    icon: Icons.person_outline,
                    text: SlotFormatters.instructorLabel(
                      slot.instructorInfo.name,
                    ),
                  ),
                  SizedBox(height: tokens.spacingSm),
                ],
                _SummaryRow(
                  icon: Icons.backpack_outlined,
                  text: equipmentLabel,
                ),
                SizedBox(height: tokens.spacingLg),
                const Divider(),
                SizedBox(height: tokens.spacingMd),
                Text(
                  '${BookingFlowMessages.totalLabel}: '
                  '${SlotFormatters.formatPrice(booking.priceTotal)}',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: tokens.spacingSm),
                Text(
                  BookingPriceCalculator.offlinePaymentHint,
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: tokens.spacingXl),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    BookingSuccessAction.myBookings,
                  ),
                  child: const Text(BookingSuccessMessages.myBookings),
                ),
                SizedBox(height: tokens.spacingSm),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(
                    BookingSuccessAction.done,
                  ),
                  child: const Text(BookingSuccessMessages.done),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        SizedBox(width: tokens.spacingSm),
        Expanded(child: Text(text)),
      ],
    );
  }
}
