import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';
import 'package:vertical_mobile/features/slots/domain/slot_formatters.dart';

class SlotDayHeader extends StatelessWidget {
  const SlotDayHeader({
    super.key,
    required this.day,
    this.now,
  });

  final DateTime day;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.verticalTokens.screenPadding,
        context.verticalTokens.spacingLg,
        context.verticalTokens.screenPadding,
        context.verticalTokens.spacingSm,
      ),
      child: Text(
        SlotFormatters.formatDayHeader(day, now: now),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
