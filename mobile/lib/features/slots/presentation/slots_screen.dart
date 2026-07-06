import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/models/slot_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/core/widgets/loadable_placeholders.dart';
import 'package:vertical_mobile/core/widgets/state_container.dart';
import 'package:vertical_mobile/features/slots/domain/slot_list_messages.dart';
import 'package:vertical_mobile/features/slots/presentation/filters/slot_filters_sheet.dart';
import 'package:vertical_mobile/features/slots/presentation/slots_list_notifier.dart';
import 'package:vertical_mobile/features/slots/presentation/widgets/slots_grouped_list_view.dart';

class SlotsScreen extends ConsumerWidget {
  const SlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(slotsListProvider);
    final notifier = ref.read(slotsListProvider.notifier);

    ref.listen(slotsListProvider, (previous, next) {
      if (next.refreshError != null && context.mounted) {
        showRefreshErrorSnackBar(context);
        notifier.clearRefreshError();
      }
    });

    final hasActiveFilters =
        SlotFilterPolicy.hasActiveFilters(listState.filters);
    final emptyReason = SlotFilterPolicy.emptyReason(
      itemCount: listState.slots.data?.length ?? 0,
      appliedFilters: listState.filters,
    );

    void openFilters() {
      showSlotFiltersSheet(context: context, ref: ref);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировки'),
        actions: [
          _FiltersAction(
            hasActiveFilters: hasActiveFilters,
            onPressed: openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          if (listState.showStaleBanner) const _StaleCacheBanner(),
          Expanded(
            child: StateContainer<List<SlotDto>>(
              state: listState.slots,
              onRetry: notifier.loadInitial,
              emptyBuilder: (_) => _RefreshableEmpty(
                onRefresh: notifier.refresh,
                title: emptyReason == SlotListEmptyReason.noFilterMatches
                    ? SlotListMessages.noFilterMatches
                    : SlotListMessages.noSlotsAvailable,
                actionLabel: emptyReason == SlotListEmptyReason.noFilterMatches
                    ? SlotListMessages.changeFiltersAction
                    : null,
                onAction: emptyReason == SlotListEmptyReason.noFilterMatches
                    ? openFilters
                    : null,
              ),
              contentBuilder: (_, slots) => RefreshIndicator(
                onRefresh: notifier.refresh,
                child: Stack(
                  children: [
                    SlotsGroupedListView(
                      slots: slots,
                      onLoadMore: notifier.loadMore,
                      isLoadingMore: listState.isLoadingMore,
                      canLoadMore: listState.canLoadMore,
                    ),
                    if (listState.slots.isRefreshing)
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersAction extends StatelessWidget {
  const _FiltersAction({
    required this.hasActiveFilters,
    required this.onPressed,
  });

  final bool hasActiveFilters;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.tune),
      label: const Text('Фильтры'),
    );

    if (!hasActiveFilters) {
      return button;
    }

    return Badge(
      label: const Text(''),
      smallSize: 8,
      child: button,
    );
  }
}

class _StaleCacheBanner extends StatelessWidget {
  const _StaleCacheBanner();

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: const Text(SlotListMessages.staleCacheBanner),
      actions: const [SizedBox.shrink()],
    );
  }
}

class _RefreshableEmpty extends StatelessWidget {
  const _RefreshableEmpty({
    required this.onRefresh,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final Future<void> Function() onRefresh;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: LoadableEmptyView(
              title: title,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
          ),
        ],
      ),
    );
  }
}
