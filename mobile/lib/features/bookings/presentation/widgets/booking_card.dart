import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/booking_models.dart';
import 'package:vertical_mobile/features/bookings/presentation/widgets/bookings_grouped_list_view.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';

class BookingSectionHeader extends StatelessWidget {
  const BookingSectionHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.spacingLg,
        tokens.screenPadding,
        tokens.spacingSm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.now,
  });

  final BookingSummaryDto booking;
  final VoidCallback onTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);
    final slot = booking.slot;
    final statusLabel = bookingStatusLabel(booking, now: now);
    final showStatusBadge = booking.status != BookingStatus.active ||
        (slot != null && !slot.startAt.isAfter(now ?? DateTime.now()));

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showStatusBadge) ...[
                Text(
                  statusLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: booking.status == BookingStatus.clubCancelled
                        ? theme.colorScheme.error
                        : null,
                  ),
                ),
                SizedBox(height: tokens.spacingSm),
              ],
              if (slot != null) ...[
                Text(
                  SlotFormatters.formatDateTimeHeader(slot.startAt),
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spacingXs),
                Text(slot.zoneFormat.name),
                SizedBox(height: tokens.spacingXs),
                Text(
                  '${slot.instructorInfo.name} · '
                  '${equipmentShortLabel(booking.equipment)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (booking.status == BookingStatus.clubCancelled &&
                  booking.cancellationReason != null) ...[
                SizedBox(height: tokens.spacingSm),
                Text(
                  booking.cancellationReason!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              SizedBox(height: tokens.spacingSm),
              Text(
                SlotFormatters.formatPrice(booking.priceTotal),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
