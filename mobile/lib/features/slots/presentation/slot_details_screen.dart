import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/availability_policy.dart';
import 'package:vertical_mobile/core/widgets/loadable_messages.dart';
import 'package:vertical_mobile/core/widgets/loadable_placeholders.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';
import 'package:vertical_mobile/features/slots/domain/slot_details_messages.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_details_notifier.dart';

class SlotDetailsScreen extends ConsumerWidget {
  const SlotDetailsScreen({
    super.key,
    required this.slotId,
  });

  final String slotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsState = ref.watch(slotDetailsProvider(slotId));
    final notifier = ref.read(slotDetailsProvider(slotId).notifier);

    ref.listen(slotDetailsProvider(slotId), (previous, next) {
      if (next.refreshError != null && context.mounted) {
        showRefreshErrorSnackBar(context);
        notifier.clearRefreshError();
      }
    });

    final errorMessage = detailsState.slot.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text(SlotDetailsMessages.title),
      ),
      body: StateContainer<SlotDto>(
        state: detailsState.slot,
        onRetry: notifier.loadInitial,
        loadingBuilder: (_) => const _SlotDetailsSkeleton(),
        errorBuilder: (context, onRetry) => LoadableErrorView(
          message: errorMessage ?? LoadableMessages.loadError,
          onRetry: onRetry,
        ),
        contentBuilder: (_, slot) => Column(
          children: [
            Expanded(
              child: LoadableRefreshable(
                onRefresh: notifier.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(context.verticalTokens.screenPadding),
                  child: _SlotDetailsBody(slot: slot),
                ),
              ),
            ),
            _SlotDetailsCta(
              slot: slot,
              onBook: () => context.push(
                AppRoutes.slotBookingPath(slot.id),
                extra: slot,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDetailsBody extends StatelessWidget {
  const _SlotDetailsBody({required this.slot});

  final SlotDto slot;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);
    final duration = SlotFormatters.formatDuration(slot.zoneFormat.durationMin);
    final description = slot.zoneFormat.description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SlotFormatters.formatDateTimeHeader(slot.startAt),
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: tokens.spacingXl),
        Text(
          slot.zoneFormat.name,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ZoneTypeBadge(type: slot.zoneFormat.type),
            if (duration != null)
              Text(
                duration,
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
        SizedBox(height: tokens.spacingXl),
        Text(
          SlotFormatters.instructorLabel(slot.instructorInfo.name),
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: tokens.spacingMd),
        Text(
          SlotFormatters.seatsDetailLabel(slot),
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: tokens.spacingSm),
        Text(
          SlotFormatters.rentalLabel(slot.freeRentalEquipment),
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: tokens.spacingSm),
        Text(
          SlotFormatters.priceDetailLabel(slot.price),
          style: theme.textTheme.titleMedium,
        ),
        if (description != null && description.isNotEmpty) ...[
          SizedBox(height: tokens.spacingXl),
          Text(
            description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _ZoneTypeBadge extends StatelessWidget {
  const _ZoneTypeBadge({required this.type});

  final ZoneFormatType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        SlotFormatters.zoneTypeLabel(type),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _SlotDetailsCta extends StatelessWidget {
  const _SlotDetailsCta({
    required this.slot,
    required this.onBook,
  });

  final SlotDto slot;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final theme = Theme.of(context);
    final canBook = AvailabilityPolicy.canBookSlot(slot);
    final isCancelled = slot.status == SlotStatus.cancelled;
    final showNoSeats = !canBook && !isCancelled && slot.freeSeats <= 0;

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
            if (isCancelled)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacingSm),
                child: Text(
                  SlotDetailsMessages.cancelledBanner,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            if (showNoSeats)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.spacingSm),
                child: Text(
                  SlotDetailsMessages.noSeats,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            FilledButton(
              onPressed: canBook ? onBook : null,
              child: const Text(SlotDetailsMessages.book),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDetailsSkeleton extends StatelessWidget {
  const _SlotDetailsSkeleton();

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
            height: 32,
            width: 220,
            decoration: BoxDecoration(
              color: placeholder,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: tokens.spacingXl),
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: placeholder,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: tokens.spacingLg),
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
