import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vertical_mobile/app/router/app_routes.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/features/slots/presentation/widgets/slot_card.dart';
import 'package:vertical_mobile/features/slots/presentation/widgets/slot_day_header.dart';

class SlotsGroupedListView extends StatelessWidget {
  const SlotsGroupedListView({
    super.key,
    required this.slots,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.canLoadMore,
    this.now,
  });

  final List<SlotDto> slots;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool canLoadMore;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final grouped = SlotFilterPolicy.groupByLocalDay(slots);
    final days = grouped.keys.toList()..sort();
    final tokens = context.verticalTokens;

    final entries = <_SlotsListEntry>[];
    for (final day in days) {
      entries.add(_SlotsListEntry.header(day));
      for (final slot in grouped[day]!) {
        entries.add(_SlotsListEntry.slot(slot));
      }
    }
    if (canLoadMore) {
      entries.add(_SlotsListEntry.loader());
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: tokens.spacingLg),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.isLoader) {
          if (!isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) => onLoadMore());
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (entry.day != null) {
          return SlotDayHeader(day: entry.day!, now: now);
        }
        final slot = entry.slot!;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.screenPadding,
            vertical: tokens.spacingXs,
          ),
          child: SlotCard(
            slot: slot,
            onTap: () => context.push(AppRoutes.slotDetailsPath(slot.id)),
          ),
        );
      },
    );
  }
}

class _SlotsListEntry {
  _SlotsListEntry.header(this.day) : slot = null, isLoader = false;

  _SlotsListEntry.slot(this.slot) : day = null, isLoader = false;

  _SlotsListEntry.loader() : day = null, slot = null, isLoader = true;

  final DateTime? day;
  final SlotDto? slot;
  final bool isLoader;
}
