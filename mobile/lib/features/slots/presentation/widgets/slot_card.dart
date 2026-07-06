import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/availability_policy.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';
import 'package:vertical_mobile/features/slots/domain/slot_list_messages.dart';

class SlotCard extends StatelessWidget {
  const SlotCard({
    super.key,
    required this.slot,
    this.onTap,
  });

  final SlotDto slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);
    final isTappable = AvailabilityPolicy.canBookSlot(slot);
    final isCancelled = slot.status == SlotStatus.cancelled;

    return Opacity(
      opacity: isTappable ? 1 : 0.55,
      child: Card(
        child: InkWell(
          onTap: isTappable ? onTap : null,
          borderRadius: BorderRadius.circular(tokens.cardRadius),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SlotFormatters.formatTime(slot.startAt),
                      style: theme.textTheme.titleLarge,
                    ),
                    SizedBox(width: tokens.spacingSm),
                    Expanded(
                      child: Text(
                        slot.zoneFormat.name,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (isCancelled)
                      _StatusChip(label: SlotListMessages.cancelled),
                  ],
                ),
                SizedBox(height: tokens.spacingSm),
                Text(
                  SlotFormatters.zoneTypeLabel(slot.zoneFormat.type),
                  style: theme.textTheme.labelLarge,
                ),
                SizedBox(height: tokens.spacingXs),
                Text(
                  slot.instructorInfo.name,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: tokens.spacingSm),
                Row(
                  children: [
                    Text(
                      SlotFormatters.seatsLabel(slot),
                      style: theme.textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      SlotFormatters.formatPrice(slot.price),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
