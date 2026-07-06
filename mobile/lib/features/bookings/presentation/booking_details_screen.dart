import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/core/domain/policies/cancellation_policy.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_placeholders.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_details_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_flow_messages.dart';
import 'package:vertical_mobile/features/bookings/domain/booking_status_labels.dart';
import 'package:vertical_mobile/features/bookings/presentation/booking_details_notifier.dart';
import 'package:vertical_mobile/features/bookings/presentation/cancel/cancel_confirm_sheet.dart';
import 'package:vertical_mobile/features/bookings/presentation/widgets/bookings_grouped_list_view.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(bookingDetailsProvider(bookingId));
    final notifier = ref.read(bookingDetailsProvider(bookingId).notifier);

    ref.listen(bookingDetailsProvider(bookingId), (previous, next) {
      if (next.successSnack != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successSnack!)),
        );
        notifier.clearSnacks();
      }
    });

    final errorMessage = detailsState.booking.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(BookingDetailsMessages.title),
      ),
      body: StateContainer<BookingDto>(
        state: detailsState.booking,
        onRetry: notifier.loadBooking,
        loadingBuilder: (_) => const _BookingDetailsSkeleton(),
        errorBuilder: (context, onRetry) => LoadableErrorView(
          message: errorMessage ?? LoadableMessages.loadError,
          onRetry: onRetry,
        ),
        contentBuilder: (_, booking) {
          final now = DateTime.now();
          final canCancel = CancellationPolicy.canClientCancel(
            status: booking.status,
            slotStartAt: booking.slot?.startAt ?? now,
            now: now,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.verticalTokens.screenPadding),
                  child: _BookingDetailsBody(booking: booking, now: now),
                ),
              ),
              _BookingDetailsActions(
                booking: booking,
                canCancel: canCancel,
                onCancel: () => _openCancelSheet(
                  context: context,
                  ref: ref,
                  booking: booking,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCancelSheet({
    required BuildContext context,
    required WidgetRef ref,
    required BookingDto booking,
  }) async {
    await showCancelConfirmSheet(
      context: context,
      bookingId: bookingId,
      booking: booking,
    );
  }
}

class _BookingDetailsBody extends StatelessWidget {
  const _BookingDetailsBody({
    required this.booking,
    required this.now,
  });

  final BookingDto booking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);
    final slot = booking.slot;
    final statusLabel = BookingStatusLabels.forBooking(
      status: booking.status,
      slotStartAt: slot?.startAt,
      now: now,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(statusLabel, style: theme.textTheme.labelLarge),
        ),
        SizedBox(height: tokens.spacingXl),
        if (slot != null) ...[
          Text(
            SlotFormatters.formatDateTimeHeader(slot.startAt),
            style: theme.textTheme.headlineSmall,
          ),
          SizedBox(height: tokens.spacingSm),
          Text(slot.zoneFormat.name, style: theme.textTheme.titleLarge),
          if (slot.zoneFormat.durationMin > 0) ...[
            SizedBox(height: tokens.spacingXs),
            Text(
              '~${slot.zoneFormat.durationMin} мин',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          SizedBox(height: tokens.spacingMd),
          Text(SlotFormatters.instructorLabel(slot.instructorInfo.name)),
        ],
        SizedBox(height: tokens.spacingMd),
        Text(equipmentFullLabel(booking.equipment)),
        SizedBox(height: tokens.spacingSm),
        Text(
          '${BookingFlowMessages.totalLabel}: '
          '${SlotFormatters.formatPrice(booking.priceTotal)}',
          style: theme.textTheme.titleMedium,
        ),
        if (booking.status == BookingStatus.clubCancelled &&
            booking.cancellationReason != null) ...[
          SizedBox(height: tokens.spacingXl),
          Text(
            '${BookingDetailsMessages.reasonPrefix} '
            '${booking.cancellationReason}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ] else if (CancellationPolicy.canClientCancel(
          status: booking.status,
          slotStartAt: slot?.startAt ?? now,
          now: now,
        )) ...[
          SizedBox(height: tokens.spacingXl),
          Text(
            BookingDetailsMessages.cancelRule,
            style: theme.textTheme.bodySmall,
          ),
        ] else if (booking.status == BookingStatus.active &&
            slot != null &&
            !slot.startAt.isAfter(now)) ...[
          SizedBox(height: tokens.spacingXl),
          Text(
            BookingDetailsMessages.slotStarted,
            style: theme.textTheme.bodySmall,
          ),
        ] else if (booking.status != BookingStatus.active) ...[
          SizedBox(height: tokens.spacingXl),
          Text(
            BookingDetailsMessages.alreadyCancelled,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _BookingDetailsActions extends StatelessWidget {
  const _BookingDetailsActions({
    required this.booking,
    required this.canCancel,
    required this.onCancel,
  });

  final BookingDto booking;
  final bool canCancel;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (!canCancel) {
      return const SizedBox.shrink();
    }

    final tokens = context.verticalTokens;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.spacingMd,
          tokens.screenPadding,
          tokens.screenPadding,
        ),
        child: OutlinedButton(
          onPressed: onCancel,
          child: const Text(BookingDetailsMessages.cancelAction),
        ),
      ),
    );
  }
}

class _BookingDetailsSkeleton extends StatelessWidget {
  const _BookingDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;
    final tokens = context.verticalTokens;

    return Padding(
      padding: EdgeInsets.all(tokens.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28,
            width: 120,
            decoration: BoxDecoration(
              color: placeholder,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: tokens.spacingXl),
          for (var i = 0; i < 5; i++) ...[
            Container(
              height: 20,
              margin: EdgeInsets.only(bottom: tokens.spacingSm),
              decoration: BoxDecoration(
                color: placeholder,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
