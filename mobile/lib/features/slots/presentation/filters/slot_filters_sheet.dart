import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/core/api/models/instructor_models.dart';
import 'package:vertical_mobile/core/domain/policies/slot_filter_policy.dart';
import 'package:vertical_mobile/features/slots/domain/slot_filters_messages.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';
import 'package:vertical_mobile/features/slots/presentation/filters/instructors_catalog_provider.dart';
import 'package:vertical_mobile/features/slots/presentation/slot_filters_notifier.dart';

Future<void> showSlotFiltersSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final applied = ref.read(slotFiltersProvider);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) {
      return SlotFiltersSheet(appliedFilters: applied);
    },
  );
}

class SlotFiltersSheet extends ConsumerStatefulWidget {
  const SlotFiltersSheet({
    super.key,
    required this.appliedFilters,
  });

  final SlotFilters appliedFilters;

  @override
  ConsumerState<SlotFiltersSheet> createState() => _SlotFiltersSheetState();
}

class _SlotFiltersSheetState extends ConsumerState<SlotFiltersSheet> {
  late SlotFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.appliedFilters.copy();
  }

  bool get _canApply => SlotFilterPolicy.isValidDateRange(_draft);

  @override
  Widget build(BuildContext context) {
    final tokens = context.verticalTokens;
    final instructorsAsync = ref.watch(instructorsCatalogProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        0,
        tokens.screenPadding,
        tokens.screenPadding,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  SlotFiltersMessages.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    SlotFiltersMessages.period,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: tokens.spacingSm),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: SlotFiltersMessages.from,
                          value: _draft.dateFrom,
                          onPick: () => _pickDate(isFrom: true),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacingSm,
                        ),
                        child: const Text('—'),
                      ),
                      Expanded(
                        child: _DateField(
                          label: SlotFiltersMessages.to,
                          value: _draft.dateTo,
                          onPick: () => _pickDate(isFrom: false),
                        ),
                      ),
                    ],
                  ),
                  if (!_canApply) ...[
                    SizedBox(height: tokens.spacingSm),
                    Text(
                      SlotFiltersMessages.invalidDateRange,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                  SizedBox(height: tokens.spacingXl),
                  Text(
                    SlotFiltersMessages.zoneType,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: tokens.spacingSm),
                  Wrap(
                    spacing: tokens.spacingSm,
                    children: [
                      FilterChip(
                        label: const Text(SlotFiltersMessages.novice),
                        selected: _draft.zoneFormatTypes
                            .contains(ZoneFormatType.novice),
                        onSelected: (_) => _toggleZoneType(
                          ZoneFormatType.novice,
                        ),
                      ),
                      FilterChip(
                        label: const Text(SlotFiltersMessages.experienced),
                        selected: _draft.zoneFormatTypes
                            .contains(ZoneFormatType.experienced),
                        onSelected: (_) => _toggleZoneType(
                          ZoneFormatType.experienced,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacingXl),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(SlotFiltersMessages.onlyAvailable),
                    value: _draft.onlyAvailable,
                    onChanged: (value) => setState(
                      () => _draft = _draft.copyWith(onlyAvailable: value),
                    ),
                  ),
                  SizedBox(height: tokens.spacingMd),
                  Text(
                    SlotFiltersMessages.instructor,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: tokens.spacingSm),
                  instructorsAsync.when(
                    loading: () => const _InstructorsSkeleton(),
                    error: (_, _) => _InstructorsError(
                      onRetry: () =>
                          ref.invalidate(instructorsCatalogProvider),
                    ),
                    data: (instructors) {
                      if (instructors.isEmpty) {
                        return Text(
                          SlotFiltersMessages.instructorsEmpty,
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      }
                      return Column(
                        children: [
                          for (final instructor in instructors)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(instructor.name),
                              value: _draft.instructorIds
                                  .contains(instructor.id),
                              onChanged: (_) =>
                                  _toggleInstructor(instructor.id),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.spacingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetDraft,
                  child: const Text(SlotFiltersMessages.reset),
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: FilledButton(
                  onPressed: _canApply ? _applyFilters : null,
                  child: const Text(SlotFiltersMessages.apply),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _draft.dateFrom : _draft.dateTo;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _draft = isFrom
          ? _draft.copyWith(dateFrom: picked)
          : _draft.copyWith(dateTo: picked);
    });
  }

  void _toggleZoneType(ZoneFormatType type) {
    final types = List<ZoneFormatType>.from(_draft.zoneFormatTypes);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    setState(() => _draft = _draft.copyWith(zoneFormatTypes: types));
  }

  void _toggleInstructor(String instructorId) {
    final ids = List<String>.from(_draft.instructorIds);
    if (ids.contains(instructorId)) {
      ids.remove(instructorId);
    } else {
      ids.add(instructorId);
    }
    setState(() => _draft = _draft.copyWith(instructorIds: ids));
  }

  void _resetDraft() {
    setState(() => _draft = SlotFilterPolicy.defaults);
  }

  void _applyFilters() {
    ref.read(slotFiltersProvider.notifier).apply(_draft);
    Navigator.of(context).pop();
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? SlotFiltersMessages.notSelected
        : SlotFormatters.formatShortDate(value!);

    return OutlinedButton(
      onPressed: onPick,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(display),
        ],
      ),
    );
  }
}

class _InstructorsSkeleton extends StatelessWidget {
  const _InstructorsSkeleton();

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: placeholder,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructorsError extends StatelessWidget {
  const _InstructorsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SlotFiltersMessages.instructorsError,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text(SlotFiltersMessages.retry),
        ),
      ],
    );
  }
}
