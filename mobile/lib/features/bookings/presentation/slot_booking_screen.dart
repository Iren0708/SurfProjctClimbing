import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/booking_price_calculator.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_placeholders.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_notifier.dart';
import 'package:vertical_mobile/features/bookings/presentation/slot_booking_params.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_success_messages.dart';
import 'package:vertical_mobile/features/bookings/presentation/success/booking_success_sheet.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';

class SlotBookingScreen extends ConsumerWidget {
  const SlotBookingScreen({
    super.key,
    required this.slotId,
    this.initialSlot,
  });

  final String slotId;
  final SlotDto? initialSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = SlotBookingParams(
      slotId: slotId,
      initialSlot: initialSlot,
    );
    final bookingState = ref.watch(slotBookingProvider(params));
    final notifier = ref.read(slotBookingProvider(params).notifier);

    ref.listen(slotBookingProvider(params), (previous, next) async {
      if (next.snackMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.snackMessage!)),
        );
        notifier.clearSnack();
      }
      if (next.refreshError != null && context.mounted) {
        showRefreshErrorSnackBar(context);
        notifier.clearRefreshError();
      }
      if (next.successBooking != null && context.mounted) {
        final booking = next.successBooking!;
        notifier.clearSuccess();
        final action = await showBookingSuccessSheet(
          context: context,
          booking: booking,
        );
        if (!context.mounted) {
          return;
        }
        context.go(
          action == BookingSuccessAction.myBookings
              ? AppRoutes.bookings
              : AppRoutes.slots,
        );
      }
    });

    final errorMessage = bookingState.slot.errorMessage;
    final isSubmitting = bookingState.submitState.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text(BookingFlowMessages.title),
      ),
      body: StateContainer<SlotDto>(
        state: bookingState.slot,
        onRetry: notifier.loadSlot,
        errorBuilder: (context, onRetry) => LoadableErrorView(
          message: errorMessage ?? LoadableMessages.loadError,
          onRetry: onRetry,
        ),
        contentBuilder: (_, slot) {
          final preview = bookingState.pricePreview;

          return Column(
            children: [
              Expanded(
                child: LoadableRefreshable(
                  onRefresh: notifier.refreshSlot,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(context.verticalTokens.screenPadding),
                    child: _SlotBookingForm(
                      slot: slot,
                      equipment: bookingState.equipment,
                      canSelectRental: bookingState.canSelectRental,
                      isSubmitting: isSubmitting,
                      onEquipmentChanged: notifier.selectEquipment,
                    ),
                  ),
                ),
              ),
              _BookingConfirmBar(
                preview: preview,
                canConfirm: bookingState.canConfirm,
                isSubmitting: isSubmitting,
                onConfirm: notifier.submitBooking,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SlotBookingForm extends StatelessWidget {
  const _SlotBookingForm({
    required this.slot,
    required this.equipment,
    required this.canSelectRental,
    required this.isSubmitting,
    required this.onEquipmentChanged,
  });

  final SlotDto slot;
  final Equipment equipment;
  final bool canSelectRental;
  final bool isSubmitting;
  final ValueChanged<Equipment> onEquipmentChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SlotFormatters.formatDateTimeHeader(slot.startAt),
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: tokens.spacingSm),
        Text(slot.zoneFormat.name, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spacingXs),
        Text(slot.instructorInfo.name, style: theme.textTheme.bodyLarge),
        SizedBox(height: tokens.spacingXl),
        Text(
          BookingFlowMessages.equipmentSection,
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: tokens.spacingSm),
        SegmentedButton<Equipment>(
          segments: [
            const ButtonSegment(
              value: Equipment.own,
              label: Text(BookingFlowMessages.ownEquipment),
            ),
            ButtonSegment(
              value: Equipment.rental,
              label: const Text(BookingFlowMessages.rentalEquipment),
              enabled: canSelectRental,
            ),
          ],
          emptySelectionAllowed: false,
          selected: {equipment},
          onSelectionChanged: isSubmitting
              ? null
              : (selection) => onEquipmentChanged(selection.first),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: tokens.spacingXs,
            left: tokens.spacingSm,
          ),
          child: const Text(
            BookingFlowMessages.rentalHint,
            style: TextStyle(fontSize: 12),
          ),
        ),
        if (!canSelectRental)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacingXs),
            child: Text(
              BookingFlowMessages.rentalUnavailable,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _BookingConfirmBar extends StatelessWidget {
  const _BookingConfirmBar({
    required this.preview,
    required this.canConfirm,
    required this.isSubmitting,
    required this.onConfirm,
  });

  final BookingPriceBreakdown? preview;
  final bool canConfirm;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.spacingMd,
          tokens.screenPadding,
          tokens.screenPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preview != null) ...[
              Text(
                '${BookingFlowMessages.totalLabel}: '
                '${SlotFormatters.formatPrice(preview!.total)}',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: tokens.spacingSm),
              Text(
                BookingPriceCalculator.offlinePaymentHint,
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: tokens.spacingMd),
            ],
            ActionLoadableButton(
              label: BookingFlowMessages.confirm,
              state: isSubmitting
                  ? const ActionLoadableState.submitting()
                  : const ActionLoadableState.idle(),
              onPressed: canConfirm ? onConfirm : null,
            ),
          ],
        ),
      ),
    );
  }
}
